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
        if var topController = UIApplication.sharedApplication().keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.view.makeToast(message, duration: 2.0, position: CSToastPositionBottom)
        }
    }
    
    class func notificationAlert(userInfo: [NSObject : AnyObject]) {
        if var topController = UIApplication.sharedApplication().keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            let title = "Notification"
            var message = "Message"
            
            if let aps = userInfo["aps"] as? NSDictionary {
                if let alert = aps["alert"] as? NSString {
                    message = alert as String
                }
            }
            
            topController.view.makeToast(
                message,
                duration: 3.0,
                position: CSToastPositionTop,
                title: title,
                image: UIImage(named: "atention_50"),
                style: nil,
                completion: {
                    (didTap: Bool) in
                    if didTap {
                        Router.sharedRouter().showHome(animated: true)
                    } else {
                        
                    }
                }
            )
        }
    }
}
