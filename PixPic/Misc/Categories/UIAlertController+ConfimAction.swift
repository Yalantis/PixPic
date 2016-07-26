//
//  UIAlertController.swift
//  PixPic
//
//  Created by anna on 3/2/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    static func showAlert(inViewController viewController: UIViewController, title: String? = nil, message: String? = nil, confimAction: (alertAction: UIAlertAction) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction.appAlertAction(title: "OK", style: .Default, handler: confimAction)
        let cancelAction = UIAlertAction.appAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        viewController.presentViewController(alert, animated: true, completion: nil)
    }
    
}