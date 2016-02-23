//
//  ApplicationAppearance.swift
//  P-effect
//
//  Created by anna on 2/23/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

protocol ApplicationAppearance {
    
    func configurateNavigationBar()
    
}

extension ApplicationAppearance where Self: UIViewController {
    
    func configurateNavigationBar() {
        self.navigationController!.navigationBar.barTintColor = UIColor.appNavBarColor
        self.navigationController!.navigationBar.translucent = false
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        self.navigationController!.navigationBar.backIndicatorImage = UIImage.appBackButton()
        self.navigationController!.navigationBar.backIndicatorTransitionMaskImage = UIImage.appBackButton()
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController!.navigationBar.topItem!.title = ""
    }

}