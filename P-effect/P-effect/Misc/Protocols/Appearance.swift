//
//  Appearance.swift
//  P-effect
//
//  Created by anna on 3/11/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

public struct Appearance {
    
    public struct Bar {
        
        var barTintColor = UIColor.appNavBarColor
        var translucent = false
        var titleTextAttributes = [NSForegroundColorAttributeName: UIColor.appWhiteColor]
        var backIndicatorImage = UIImage.appBackButton()
        var backIndicatorTransitionMaskImage = UIImage.appBackButton()
        var tintColor = UIColor.appWhiteColor
        var topItemTitle = ""

    }
    
    var statusBarStyle: UIStatusBarStyle = .LightContent
    var navigationBar = Bar()
    
}
