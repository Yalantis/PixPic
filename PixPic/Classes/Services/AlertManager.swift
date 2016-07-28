//
//  AlertManager.swift
//  PixPic
//
//  Created by Jack Lapin on 17.01.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import Toast

private let notification = NSLocalizedString("notification", comment: "")
private let simpleAlertDuration: NSTimeInterval = 2
private let notificationAlertDuration: NSTimeInterval = 3

protocol AlertManagerDelegate: FeedPresenter, ProfilePresenter {
    
    func showSimpleAlert(message: String)
    func showNotificationAlert(userInfo: [NSObject: AnyObject]?, message: String?)
    
}

extension AlertManagerDelegate {
    
    func showSimpleAlert(message: String) {
        let style = CSToastStyle(defaultStyle: ())
        currentViewController.view.makeToast(message, duration: simpleAlertDuration, position: CSToastPositionBottom, style: style)
    }
    
    func showNotificationAlert(userInfo: [NSObject: AnyObject]?, message: String?) {
        let title = notification
        var message = message
        guard let notificationObject = RemoteNotificationParser.parse(userInfo) else  {
            return
        }
        
        switch notificationObject {
        case .NewPost(let alert, _):
            message = alert
            
        case .NewFollower(let alert, _):
            message = alert
        }
        
        let isControllerWaitingForResponse = (currentViewController.presentedViewController as? UIAlertController) != nil
        
        let style = CSToastStyle(defaultStyle: ())
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
                style: style,
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
    
    static let sharedInstance = AlertManager()
    
    private weak var delegate: AlertManagerDelegate?
    
    private init() {
    }
    
    func setAlertDelegate(delegate: AlertManagerDelegate) {
        self.delegate = delegate
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
            if let notificationObject = RemoteNotificationParser.parse(userInfo) {
                switch notificationObject {
                case .NewFollower(_, let userId):
                    delegate?.showProfile(userId)
                    
                default:
                    NSNotificationCenter.defaultCenter().postNotificationName(
                        Constants.NotificationName.NewPostIsReceaved,
                        object: nil
                    )
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
