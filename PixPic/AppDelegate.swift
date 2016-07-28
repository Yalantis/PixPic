//
//  AppDelegate.swift
//  PixPic
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
import XCGLogger
import Toast

let log = XCGLogger.defaultInstance()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private lazy var router = LaunchRouter()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        setupParse()
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)

        Fabric.with([Crashlytics.self])

        if application.applicationState != .Background {
            setupParseAnalyticsWithLaunchOptions(launchOptions)
        }
        UIApplication.sharedApplication().statusBarStyle = .LightContent

        log.setup()
        setupToast()
        SettingsHelper.setupDefaultValues()
        setupRouter()
                
        return true
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
        if User.isAbsent {
            completionHandler(.NoData)
        } else {
            completionHandler(.NewData)
        }
    }

    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
        resetBadge()
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        resetBadge()
    }
    
    private func resetBadge() {
        let currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.badge = 0
        currentInstallation.saveEventually()
    }
    
    private func setupParse() {
        User.registerSubclass()
        Parse.enableLocalDatastore()
        Parse.setApplicationId(Constants.ParseApplicationId.AppID, clientKey: Constants.ParseApplicationId.ClientKey)
    }
    
    private func setupParseAnalyticsWithLaunchOptions(launchOptions: [NSObject: AnyObject]?) {
        let oldPushHandlerOnly = !self.respondsToSelector(#selector(UIApplicationDelegate.application(_:didReceiveRemoteNotification:fetchCompletionHandler:)))
        let noPushPayload = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey]
        if oldPushHandlerOnly || noPushPayload != nil {
            PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        }
    }
    
    private func setupRouter() {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window!.makeKeyAndVisible()
        router.execute(window!)
    }
    
    private func setupToast() {
        let style = CSToastStyle(defaultStyle: ())
        style.backgroundColor = UIColor.clearColor()
        CSToastManager.setSharedStyle(style)
    }
}