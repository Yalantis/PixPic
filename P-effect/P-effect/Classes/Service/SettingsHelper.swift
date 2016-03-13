//
//  SettingsHelper.swift
//  P-effect
//
//  Created by AndrewPetrov on 3/2/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class SettingsHelper {
    
    private static let remoteNotificationsKey = Constants.UserDefaultsKeys.RemoteNotifications
    
    static var isRemoteNotificationsEnabled: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(remoteNotificationsKey)
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: remoteNotificationsKey)
            RemoteNotificationManager.switchNotificationAvailbilityState(to: newValue)
        }
    }
    
    static func setupDefaultValues() {
        let isThisFirstTimeAppLaunched = NSUserDefaults.standardUserDefaults().objectForKey(remoteNotificationsKey) == nil
        if isThisFirstTimeAppLaunched {
            isRemoteNotificationsEnabled = true
        }
    }

}

