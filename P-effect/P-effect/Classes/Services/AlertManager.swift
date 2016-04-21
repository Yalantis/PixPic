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
private let simpleAlertDuration: NSTimeInterval = 2
private let notificationAlertDuration: NSTimeInterval = 3

protocol AlertManagerDelegate: FeedPresenter, ProfilePresenter {
    
    func showSimpleAlert(message: String)
    func showNotificationAlert(userInfo: [NSObject: AnyObject]?, message: String?)
    
}

extension AlertManagerDelegate {
    
    func showSimpleAlert(message: String) {
        currentViewController.view.makeToast(message, duration: simpleAlertDuration, position: CSToastPositionBottom)
    }
    
    func showNotificationAlert(userInfo: [NSObject: AnyObject]?, message: String?) {
        let title = notification
        var message = message
        guard let notificationObject = RemoteNotificationHelper.parse(userInfo) else  {
            return
        }
        
        switch notificationObject {
        case .NewPost(let alert, _):
            message = alert
            
        case .NewFollower(let alert, _):
            message = alert
        }
        
        let isControllerWaitingForResponse = (currentViewController.presentedViewController as? UIAlertController) != nil
        
        if isControllerWaitingForResponse {
            PushNotificationQueue.addObjectToQueue(message)
        } else {
            PushNotificationQueue.clearQueue()
            currentViewController.view.makeToast(
                message,
                duration: notificationAlertDuration,
                position: CSToastPositionTop,
                title: title,
                image: UIImage(named: "icon_notification"),
                style: nil,
                completion: { [weak self] didTap in
                    if didTap {
                        switch notificationObject {
                        case .NewFollower(_, let userId):
                            self?.showProfile(userId)
                            break
                            
                        default:
                            self?.showFeed()
                            break
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
            if let notificationObject = RemoteNotificationHelper.parse(userInfo) {
                switch notificationObject {
                case .NewFollower(_, let userId):
                    delegate?.showProfile(userId)
                    
                default:
                    delegate?.showFeed()
                }
            }
        }
        if application.applicationState == .Active {
            showNotificationAlert(userInfo, message: nil)
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
    }
    
}
