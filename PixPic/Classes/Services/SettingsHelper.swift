//
//  SettingsHelper.swift
//  PixPic
//
//  Created by AndrewPetrov on 3/2/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class SettingsHelper {

    fileprivate static let remoteNotificationsKey = Constants.UserDefaultsKeys.remoteNotifications
    fileprivate static let followedPostsKey = Constants.UserDefaultsKeys.followedPosts

    static var isRemoteNotificationsEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: remoteNotificationsKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: remoteNotificationsKey)
            RemoteNotificationHelper.setNotificationsAvailable(newValue)
        }
    }

    static var isShownOnlyFollowingUsersPosts: Bool {
        get {
            return UserDefaults.standard.bool(forKey: followedPostsKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: followedPostsKey)
        }
    }

    static func setupDefaultValues() {
        let isThisFirstTimeAppLaunched = UserDefaults.standard.object(forKey: remoteNotificationsKey) == nil
        if isThisFirstTimeAppLaunched {
            isRemoteNotificationsEnabled = true
            isShownOnlyFollowingUsersPosts = false
        }
    }

}
