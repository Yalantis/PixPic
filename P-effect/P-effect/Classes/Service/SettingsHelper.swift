//
//  SettingsHelper.swift
//  P-effect
//
//  Created by AndrewPetrov on 3/2/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class SettingsHelper {
    
    static var remoteNotificationsState: Bool? {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey(Constants.UserDefaultsKeys.RemoteNotifications) as? Bool
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue!, forKey: Constants.UserDefaultsKeys.RemoteNotifications)
            RemoteNotificationManager.switchNotofications(toState: newValue!)
        }
    }
    
}

