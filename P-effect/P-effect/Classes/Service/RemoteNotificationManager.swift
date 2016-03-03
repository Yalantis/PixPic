//
//  RemoteNotificationManager.swift
//  P-effect
//
//  Created by AndrewPetrov on 3/3/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class RemoteNotificationManager {
    
    static func switchNotofications(toState state: Bool) {
        let application = UIApplication.sharedApplication()
        if state {
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