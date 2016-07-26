//
//  RemoteNotificationManager.swift
//  PixPic
//
//  Created by Jack Lapin on 14.03.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class RemoteNotificationHelper {
    
    static func setNotificationsAvailable(enabled: Bool) {
        let application = UIApplication.sharedApplication()
        if enabled {
            let settings = UIUserNotificationSettings(
                forTypes: [.Alert, .Badge, .Sound],
                categories: nil
            )
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            application.unregisterForRemoteNotifications()
        }
    }
    
}