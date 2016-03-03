//
//  SettingsHelper.swift
//  P-effect
//
//  Created by AndrewPetrov on 3/2/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class SettingsHelper {
    
    static func switchNotofications(toState state: Bool) {
        NSUserDefaults.standardUserDefaults().setBool(state, forKey: Constants.UserDefaultsKeys.Notifications)
    }
    
    static var notificationsState: Bool? {
        return NSUserDefaults.standardUserDefaults().objectForKey(Constants.UserDefaultsKeys.Notifications) as? Bool
    }
    
}