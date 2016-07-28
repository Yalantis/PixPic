//
//  NavigationControllerAppearanceContext.swift
//  PixPic
//
//  Created by anna on 3/14/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation
import UIKit

protocol NavigationControllerAppearanceContext: class {
    
    func prefersNavigationControllerBarHidden(navigationController: UINavigationController) -> Bool
    func prefersNavigationControllerToolbarHidden(navigationController: UINavigationController) -> Bool
    func preferredNavigationControllerAppearance(navigationController: UINavigationController) -> Appearance?
    
    func setNeedsUpdateNavigationControllerAppearance()
    
}

extension NavigationControllerAppearanceContext {
    
    func prefersNavigationControllerBarHidden(navigationController: UINavigationController) -> Bool {
        return false
    }
    
    func prefersNavigationControllerToolbarHidden(navigationController: UINavigationController) -> Bool {
        return true
    }
    
    func preferredNavigationControllerAppearance(navigationController: UINavigationController) -> Appearance? {
        return nil
    }
    
    func setNeedsUpdateNavigationControllerAppearance() {
        if let viewController = self as? UIViewController,
            navigationController = viewController.navigationController as? AppearanceNavigationController {
                navigationController.updateAppearanceForViewController(viewController)
        }
    }
    
}
