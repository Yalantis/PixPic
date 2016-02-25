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
        navigationController?.navigationBar.barTintColor = UIColor.appNavBarColor
        navigationController?.navigationBar.translucent = false
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.appWhiteColor]
        navigationController?.navigationBar.backIndicatorImage = UIImage.appBackButton()
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage.appBackButton()
        navigationController?.navigationBar.tintColor = UIColor.appWhiteColor
        navigationController?.navigationBar.topItem!.title = ""
    }

}