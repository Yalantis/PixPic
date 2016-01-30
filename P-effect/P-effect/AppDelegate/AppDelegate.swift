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
        FBSDKApplicationDelegate.sharedInstance().application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        setupParse()

        Parse.setApplicationId(
            Constants.ParseApplicationId.AppID,
            clientKey: Constants.ParseApplicationId.ClientKey
        )
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        Fabric.with([Crashlytics.self])
        
        if application.applicationState != UIApplicationState.Background {
            let oldPushHandlerOnly = !self.respondsToSelector(Selector("application:didReceiveRemoteNotification:fetchCompletionHandler:"))
            let noPushPayload: AnyObject? = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey]
            if oldPushHandlerOnly || noPushPayload != nil {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        setupNotifications(application)
        setupUI()
        
        Router.sharedRouter().onStart(true)
        return true
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private func setupParse() {
        User.registerSubclass()
        Parse.enableLocalDatastore()

    }
    
    private func setupUI() {
        let buttonTitlePosition = Constants.BackButtonTitle.HideTitlePosition
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(
            buttonTitlePosition,
            forBarMetrics: .Default
        )
    }
    
    private func setupNotifications(application: UIApplication) {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "onTokenUpdated:",
            name:FBSDKAccessTokenDidChangeNotification,
            object: nil
        )
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
        installation.saveInBackground()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        if application.applicationState == .Inactive  {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
        PFPush.handlePush(userInfo)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        
        if application.applicationState == .Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
            Router.sharedRouter().showHome(animated: true)
        }
        
        if application.applicationState == .Active {
            AlertService.notificationAlert(userInfo)
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
        
        if PFUser.currentUser() != nil {
            completionHandler(UIBackgroundFetchResult.NewData)
        } else {
            completionHandler(UIBackgroundFetchResult.NoData)
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
    
    func onTokenUpdated(notification: NSNotification) {
        print(notification)
    }
    
}