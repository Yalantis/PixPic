//
//  Appearance.swift
//  PixPic
//
//  Created by anna on 3/11/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

struct Appearance: Equatable {
    
    struct Bar: Equatable {
        
        var barTintColor = UIColor.appNavBarColor()
        var translucent = false
        var titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.appWhiteColor(),
            NSFontAttributeName: UIFont(name: "Radikal", size: 18)!
        ]
        var tintColor = UIColor.appWhiteColor()
        var topItemTitle = ""

    }
    
    var title = ""
    var statusBarStyle: UIStatusBarStyle = .LightContent
    var navigationBar = Bar()
    
}

func ==(lhs: Appearance.Bar, rhs: Appearance.Bar) -> Bool {
    return lhs.barTintColor == rhs.barTintColor &&
        lhs.translucent == rhs.translucent &&
        lhs.titleTextAttributes == rhs.titleTextAttributes &&
        lhs.tintColor == rhs.tintColor &&
        lhs.topItemTitle == rhs.topItemTitle
}

func ==(lhs: Appearance, rhs: Appearance) -> Bool {
    return lhs.statusBarStyle == rhs.statusBarStyle &&
        lhs.navigationBar == rhs.navigationBar &&
        lhs.title == rhs.title
}