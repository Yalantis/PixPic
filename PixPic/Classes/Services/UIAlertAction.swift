//
//  AlertAction.swift
//  PixPic
//
//  Created by AndrewPetrov on 6/29/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

extension UIAlertAction {

    static func appAlertAction(title: String?, style: UIAlertActionStyle, color: UIColor = UIColor.appTintColor(), handler: ((UIAlertAction) -> Void)?) -> UIAlertAction {
        let action = UIAlertAction(title: title, style: style, handler: handler)
        action.setValue(color, forKey: "titleTextColor")

        return action
    }

}
