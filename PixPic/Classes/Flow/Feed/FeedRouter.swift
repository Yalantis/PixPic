//
//  FeedRouter.swift
//  PixPic
//
//  Created by AndrewPetrov on 2/17/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class FeedRouter: AlertManagerDelegate, ProfilePresenter, PhotoEditorPresenter, AuthorizationPresenter, FeedPresenter,
SettingsPresenter {

    fileprivate(set) weak var locator: ServiceLocator!
    fileprivate(set) weak var currentViewController: UIViewController!

    init(locator: ServiceLocator) {
        self.locator = locator
    }

}

extension FeedRouter: Router {

    func execute(_ context: UIWindow) {
        execute(context, userInfo: nil)
    }

    func execute(_ context: UIWindow, userInfo: AnyObject?) {
        let feedViewController = FeedViewController.create()
        feedViewController.setRouter(self)
        feedViewController.setLocator(locator)
        currentViewController = feedViewController
        let navigationController = AppearanceNavigationController(rootViewController: feedViewController)
        context.rootViewController = navigationController
    }

}
