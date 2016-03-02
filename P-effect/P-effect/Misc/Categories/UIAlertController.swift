//
//  UIAlertController.swift
//  P-effect
//
//  Created by anna on 3/2/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    static func showAlert(inViewController viewController: UIViewController, title: String? = nil, message: String? = nil, actions: [String] ,confimAction: (alertAction: UIAlertAction) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
        
        for actionTitle in actions {
            let action = UIAlertAction(title: actionTitle, style: .Default, handler: confimAction)
            alert.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style:  .Cancel, handler: nil)
        alert.addAction(cancelAction)
        
        viewController.presentViewController(alert, animated: true, completion: nil)
    }
    
}