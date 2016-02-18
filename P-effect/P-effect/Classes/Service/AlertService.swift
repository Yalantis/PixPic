//
//  AlertService.swift
//  P-effect
//
//  Created by Jack Lapin on 17.01.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import Toast

class AlertService: NSObject {
    
    static var topPresenter: FeedPresenter!
    static var allowToDisplay = true
    
    class func simpleAlert(message: String?) {
        topPresenter.currentViewController.view.makeToast(message, duration: 2.0, position: CSToastPositionBottom)
    }
    
    class func notificationAlert(userInfo: [NSObject : AnyObject] = [:], var message: String? = nil) {
        
        guard let topViewController = topPresenter.currentViewController else {
            return
        }
        let title = "Notification"
        if let aps = userInfo["aps"] as? [String:String] {
            message = aps["alert"]
        }
        
        let isControllersWaitingForResponse = (topViewController as? UIAlertController) != nil
        
        if isControllersWaitingForResponse || !allowToDisplay {
            PushNotificationQueue.addObjectInQueue(message)
        } else {
            PushNotificationQueue.clearQueue()
            topViewController.view.makeToast(
                message,
                duration: 3.0,
                position: CSToastPositionTop,
                title: title,
                image: UIImage(named: "ic_notification"),
                style: nil,
                completion: {
                    (didTap: Bool) in
                    if didTap {
                        topPresenter.goToFeed()
                    }
                }
            )
        }
    }
    
    private func configNotification(message: String) -> AFDropdownNotification {
        let notification = AFDropdownNotification()
        notification.titleText = "Some news"
        notification.subtitleText = "New amazing photos appears by..."
        notification.image = UIImage(named: "ic_notification")
        notification.topButtonText = "Show";
        notification.bottomButtonText = "Cancel";
        
        notification.listenEventsWithBlock {
            event in
            switch event {
            case .TopButton:
                notification.dismissWithGravityAnimation(true)
                AlertService.topPresenter.goToFeed()
            case .BottomButton:
                notification.dismissWithGravityAnimation(true)
            case .Tap:
                notification.dismissWithGravityAnimation(true)
            }
        }
        return notification
    }
    
}

