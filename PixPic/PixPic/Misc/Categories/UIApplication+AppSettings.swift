//
//  UIApplication+AppSettings.swift
//  PixPic
//
//  Created by Jack Lapin on 03.02.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//


extension UIApplication {
    
    static func redirectToAppSettings() {
        UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
    }

}
