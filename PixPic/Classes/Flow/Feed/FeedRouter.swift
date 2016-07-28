//
//  FeedRouter.swift
//  PixPic
//
//  Created by AndrewPetrov on 2/17/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class FeedRouter: AlertManagerDelegate, ProfilePresenter, PhotoEditorPresenter, AuthorizationPresenter, FeedPresenter, SettingsPresenter {
    
    private(set) weak var locator: ServiceLocator!
    private(set) weak var currentViewController: UIViewController!
    
    init(locator: ServiceLocator) {
        self.locator = locator
    }
    
}

extension FeedRouter: Router {
        
    func execute(context: UIWindow) {
        let feedViewController = FeedViewController.create()
        feedViewController.setRouter(self)
        feedViewController.setLocator(locator)
        currentViewController = feedViewController
        let navigationController = AppearanceNavigationController(rootViewController: feedViewController)
        context.rootViewController = navigationController
    }
    
}
