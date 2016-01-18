//
//  AppDelegate.swift
//  P-effect
//
//  Created by Jack Lapin on 14.01.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
   
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //TODO: Save string constants in the constants file
        Parse.setApplicationId("8yjIQdP3FPBBe9VwRcsfJrth2dWSDBjsFPC47v2c", clientKey: "fJwIVMqkD8DlpYNzfyrESiKQTfqzVU6IrAJnTef3")
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        if User.currentUser() != nil {
            User.enableRevocableSessionInBackground()
        } else {
            //TODO: Authorize user
        }
        
        Fabric.with([Crashlytics.self])
        return true
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
    }
    
}