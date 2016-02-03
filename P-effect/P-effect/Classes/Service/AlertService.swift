//
//  AlertService.swift
//  P-effect
//
//  Created by Jack Lapin on 17.01.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class AlertService: NSObject {
    
    class func simpleAlert(message: String?) {
        if let topController = AlertService().topController() {
            topController.view.makeToast(message, duration: 2.0, position: CSToastPositionBottom)
        }
    }
    
    class func notificationAlert(userInfo: [NSObject : AnyObject] = [:], var message: String? = nil) {
        
        guard let topController = AlertService().topController() else {
            return
        }
        let title = "Notification"
        if let _ = message {
        } else {
            if let aps = userInfo["aps"] as? NSDictionary {
                if let alert = aps["alert"] as? NSString {
                    message = alert as String
                }
            }
        }
        
        let isControllersWaitingForResponse = (topController as? UIAlertController) != nil ||
            (topController as? PhotoEditorViewController) != nil
        
        if isControllersWaitingForResponse {
            PushNotificationQueue.addObjectInQueue(message)
        } else {
            PushNotificationQueue.clearQueue()
            topController.view.makeToast(
                message,
                duration: 3.0,
                position: CSToastPositionTop,
                title: title,
                image: UIImage(named: "ic_notification"),
                style: nil,
                completion: {
                    (didTap: Bool) in
                    if didTap {
                        Router.sharedRouter().showHome(animated: true)
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
                Router.sharedRouter().showHome(animated: true)
            case .BottomButton:
                notification.dismissWithGravityAnimation(true)
            case .Tap:
                notification.dismissWithGravityAnimation(true)
            }
        }
        return notification
    }
    
    private func topController() -> UIViewController? {
        if var topController = UIApplication.sharedApplication().keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
    
    
}

