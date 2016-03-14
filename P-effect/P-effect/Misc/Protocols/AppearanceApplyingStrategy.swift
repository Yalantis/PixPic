//
//  AppearanceApplyingStrategy.swift
//  P-effect
//
//  Created by anna on 3/11/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

public class AppearanceApplyingStrategy {
    
    public func apply(appearance: Appearance?, toNavigationController navigationController: UINavigationController, animated: Bool) {
        if let appearance = appearance {
            let navigationBar = navigationController.navigationBar
            
            if !navigationController.navigationBarHidden {
                navigationBar.barTintColor = appearance.navigationBar.barTintColor
                navigationBar.translucent = appearance.navigationBar.translucent
                navigationBar.titleTextAttributes = appearance.navigationBar.titleTextAttributes
                navigationBar.backIndicatorImage = appearance.navigationBar.backIndicatorImage
                navigationBar.backIndicatorTransitionMaskImage =
                    appearance.navigationBar.backIndicatorTransitionMaskImage
                navigationBar.tintColor = appearance.navigationBar.tintColor
                navigationBar.topItem!.title = appearance.navigationBar.topItemTitle
            }
        }
    }
    
}