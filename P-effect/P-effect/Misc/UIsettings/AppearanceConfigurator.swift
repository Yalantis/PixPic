//
//  AppearanceConfigurator.swift
//  Achievity
//
//  Created by Dmitriy Demchenko on 12/21/15.
//  Copyright © 2015 Konstantin Safronov. All rights reserved.
//

import UIKit

private let TabBarBackgroundColor = UIColor(colorLiteralRed: 37.0/255.0, green: 167.0/255.0, blue: 218.0/255.0, alpha: 1.0)
private let DefaultItemColor = UIColor(colorLiteralRed: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.6)
private let NavigationBarTitleFontSize: CGFloat = 17.0
private let TabBarItemTitleFontSize: CGFloat = 10.0

class AppearanceConfigurator {
    
    class func configurateNavigationBarAndStatusBar() {
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        
        UINavigationBar.appearance().barTintColor = UIColor.appBaseBlueColor()
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().backIndicatorImage = UIImage.appBackButton()
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage.appBackButton()
    }
    
}