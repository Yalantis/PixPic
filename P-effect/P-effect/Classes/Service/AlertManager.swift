//
//  AlertManager.swift
//  P-effect
//
//  Created by Jack Lapin on 17.01.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import Toast

private let notification = "Notification"

protocol AlertManagerDelegate: FeedPresenter, ProfilePresenter {
    
    func showSimpleAlert(message: String)
    func showNotificationAlert(userInfo: [NSObject: AnyObject]?, message: String?)
    
}

extension AlertManagerDelegate {
    
    func showSimpleAlert(message: String) {
        currentViewController.view.makeToast(message, duration: 2.0, position: CSToastPositionBottom)
    }
    
    func showNotificationAlert(userInfo: [NSObject: AnyObject]?, var message: String?) {
        let title = notification
        var followerId: String?
        if let info = RemoteNotificationHelper.parse(userInfo) {
            message = info.message
            followerId = info.followerId
        }
        
        let isControllerWaitingForResponse = (currentViewController.presentedViewController as? UIAlertController) != nil
        
        if isControllerWaitingForResponse {
            PushNotificationQueue.addObjectInQueue(message)
        } else {
            PushNotificationQueue.clearQueue()
            currentViewController.view.makeToast(
                message,
                duration: 3.0,
                position: CSToastPositionTop,
                title: title,
                image: UIImage(named: "ic_notification"),
                style: nil,
                completion: { [weak self] didTap in
                    if didTap {
                        if let userId = followerId {
                            self?.showProfile(userId)
                        } else {
                            self?.showFeed()
                        }
                    }
                }
            )
        }
    }
    
}

final class AlertManager {
    
    static let instance = AlertManager()
    
    private weak var delegate: AlertManagerDelegate?
    
    private init() {
    }
    
    static var sharedInstance: AlertManager {
        return instance
    }
    
    func registerAlertListener(listener: AlertManagerDelegate) {
        delegate = listener
    }
    
    func showSimpleAlert(message: String) {
        delegate?.showSimpleAlert(message)
    }
    
    func showNotificationAlert(userInfo: [NSObject: AnyObject]?, message: String?) {
        delegate?.showNotificationAlert(userInfo, message: message)
    }
    
    func handlePush(userInfo: [NSObject: AnyObject]) {
        let application = UIApplication.sharedApplication()
        if application.applicationState == .Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
            if let info = RemoteNotificationHelper.parse(userInfo), userId = info.followerId {
                delegate?.showProfile(userId)
            } else {
                delegate?.showFeed()
            }
        }
        if application.applicationState == .Active {
            showNotificationAlert(userInfo, message: nil)
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
    }
    
}
