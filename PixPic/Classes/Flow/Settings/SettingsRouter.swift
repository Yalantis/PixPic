//
//  SettingsRouter.swift
//  PixPic
//
//  Created by AndrewPetrov on 3/1/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class SettingsRouter: AlertManagerDelegate, FeedPresenter, AuthorizationPresenter {
    
    private(set) weak var currentViewController: UIViewController!
    private(set) weak var locator: ServiceLocator!
    
    init(locator: ServiceLocator) {
        self.locator = locator
    }
    
}

extension SettingsRouter: Router {
        
    func execute(context: AppearanceNavigationController) {
        let settingsController = SettingsViewController.create()
        settingsController.router = self
        settingsController.setLocator(locator)
        currentViewController = settingsController
        context.showViewController(settingsController, sender: self)
    }
    
}
