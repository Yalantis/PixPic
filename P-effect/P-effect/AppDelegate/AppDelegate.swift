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
import Parse
import ParseFacebookUtilsV4
import Bolts

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private lazy var router = FeedRouter()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        FBSDKApplicationDelegate.sharedInstance().application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        setupParse()
        setupAppearance()
        setupRemoteNotifications(application)
        
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        Fabric.with([Crashlytics.self])
        
        if application.applicationState != UIApplicationState.Background {
            let oldPushHandlerOnly = !self.respondsToSelector("application:didReceiveRemoteNotification:fetchCompletionHandler:")
            let noPushPayload = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey]
            if oldPushHandlerOnly || noPushPayload != nil {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window!.makeKeyAndVisible()
        
        router.execute(window!)
        return true
    }
    
    private func setupParse() {
        User.registerSubclass()
        Parse.enableLocalDatastore()
        Parse.setApplicationId(Constants.ParseApplicationId.AppID, clientKey: Constants.ParseApplicationId.ClientKey)
    }
    
    private func setupAppearance() {
        let buttonTitlePosition = Constants.BackButtonTitle.HideTitlePosition
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(
            buttonTitlePosition,
            forBarMetrics: .Default
        )
        AppearanceConfigurator.configurateNavigationBarAndStatusBar()
    }
    
    private func setupRemoteNotifications(application: UIApplication) {
        let settings = UIUserNotificationSettings(
            forTypes: [.Alert, .Badge, .Sound],
            categories: nil
        )
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.channels = ["global"]
        installation.saveEventually()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject: AnyObject]) {
        if application.applicationState == .Inactive  {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
        PFPush.handlePush(userInfo)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject: AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        AlertManager.sharedInstance.handlePush(userInfo)
        if PFUser.currentUser() != nil {
            completionHandler(.NewData)
        } else {
            completionHandler(.NoData)
        }
    }

    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
        let currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.badge = 0
        currentInstallation.saveEventually()
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        let currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.badge = 0
        currentInstallation.saveEventually()
    }
    
}