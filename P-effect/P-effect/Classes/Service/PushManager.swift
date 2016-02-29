//
//  PushManager.swift
//  P-effect
//
//  Created by AndrewPetrov on 2/29/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class PushManager {
    
    static func handlePush(userInfo: [NSObject : AnyObject], router: FeedPresenter){
        let application = UIApplication.sharedApplication()
        if application.applicationState == .Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
            router.showFeed()
        }
        if application.applicationState == .Active {
            AlertManager.sharedInstance.showNotificationAlert(userInfo, message: nil)
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
    }
    
}