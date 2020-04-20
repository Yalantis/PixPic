//
//  SettingsRouter.swift
//  PixPic
//
//  Created by AndrewPetrov on 3/1/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class SettingsRouter: AlertManagerDelegate, FeedPresenter, AuthorizationPresenter {

    fileprivate(set) weak var currentViewController: UIViewController!
    fileprivate(set) weak var locator: ServiceLocator!

    init(locator: ServiceLocator) {
        self.locator = locator
    }

}

extension SettingsRouter: Router {

    func execute(_ context: AppearanceNavigationController) {
        execute(context, userInfo: nil)
    }

    func execute(_ context: AppearanceNavigationController, userInfo: AnyObject?) {
        let settingsController = SettingsViewController.create()
        settingsController.router = self
        settingsController.setLocator(locator)
        currentViewController = settingsController
        context.showViewController(settingsController, sender: self)
    }

}
