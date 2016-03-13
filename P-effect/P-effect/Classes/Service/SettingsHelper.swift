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
    private static let isFirstTimeAppLaunchedKey = Constants.UserDefaultsKeys.isFirstTimeAppLaunched
    
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
        if NSUserDefaults.standardUserDefaults().objectForKey(isFirstTimeAppLaunchedKey) == nil {
            isRemoteNotificationsEnabled = true
            NSUserDefaults.standardUserDefaults().setBool(false, forKey: isFirstTimeAppLaunchedKey)
        }
    }

}

