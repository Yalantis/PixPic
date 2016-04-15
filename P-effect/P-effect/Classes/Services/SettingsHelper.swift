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
    private static let followedPostsKey = Constants.UserDefaultsKeys.FollowedPosts
    
    static var isRemoteNotificationsEnabled: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(remoteNotificationsKey)
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: remoteNotificationsKey)
            RemoteNotificationManager.switchNotificationAvailbilityState(to: newValue)
        }
    }
    
    static var isShownOnlyFollowingUsersPosts: Bool {
        get {
            return NSUserDefaults.standardUserDefaults().boolForKey(followedPostsKey)
        }
        set {
            NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: followedPostsKey)
        }
    }
    
    static func setupDefaultValues() {
        let isThisFirstTimeAppLaunched = NSUserDefaults.standardUserDefaults().objectForKey(remoteNotificationsKey) == nil
        if isThisFirstTimeAppLaunched {
            isRemoteNotificationsEnabled = true
            isShownOnlyFollowingUsersPosts = false
        }
    }

}

