//
//  FeedRouter.swift
//  P-effect
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
    
    typealias Context = UIWindow
    
    func execute(context: UIWindow) {
        let feedViewController = FeedViewController.create()
        feedViewController.router = self
        feedViewController.setLocator(locator)
        self.currentViewController = feedViewController
        let navigationController = UINavigationController(rootViewController: feedViewController)
        context.rootViewController = navigationController
    }
    
}
