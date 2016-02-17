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
    
    static var allowToDisplay = true
    
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
        if let aps = userInfo["aps"] as? [String:String] {
            message = aps["alert"]
        }
        
        let isControllersWaitingForResponse = (topController as? UIAlertController) != nil
        
        if isControllersWaitingForResponse || !allowToDisplay {
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

