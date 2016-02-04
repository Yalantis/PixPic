//
//  AppearanceConfigurator.swift
//  Achievity
//
//  Created by Dmitriy Demchenko on 12/21/15.
//  Copyright © 2015 Konstantin Safronov. All rights reserved.
//

import UIKit

private let NavigationBarTitleFontSize: CGFloat = 17.0
private let TabBarItemTitleFontSize: CGFloat = 10.0

class AppearanceConfigurator {
    
    class func configurateNavigationBarAndStatusBar() {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        UINavigationBar.appearance().barTintColor = UIColor.appNavBarColor()
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        UINavigationBar.appearance().backIndicatorImage = UIImage.appBackButton()
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage.appBackButton()
    }
    
}