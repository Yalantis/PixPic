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
    
}
