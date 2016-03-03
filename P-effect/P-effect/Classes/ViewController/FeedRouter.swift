//
//  FeedRouter.swift
//  P-effect
//
//  Created by AndrewPetrov on 2/17/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class FeedRouter: AlertManagerDelegate, ProfilePresenter, PhotoEditorPresenter, AuthorizationPresenter, FeedPresenter {
    
    private(set) var locator: ServiceLocator!
    private(set) weak var currentViewController: UIViewController!
    
    init() {
        locator = ServiceLocator()
        locator.registerService(PostService())
        locator.registerService(EffectsService())
        locator.registerService(UserService())
        locator.registerService(ValidationService())
        locator.registerService(AuthService())
        locator.registerService(ImageLoaderService())
    }
}

extension FeedRouter: Router {
    
    typealias Context = UIWindow
    
    func execute(context: UIWindow) {
        if User.currentUser() == nil {
            (locator.getService() as AuthService).anonymousLogIn(
                completion: { [weak self] _  in
                    self?.presentFeed(context)
                },
                failure: { error in
                    if let error = error {
                        handleError(error)
                    }
            })
        } else {
            presentFeed(context)
        }
    }
    
    private func presentFeed(context: UIWindow) {
        let feedViewController = FeedViewController.create()
        feedViewController.router = self
        feedViewController.setLocator(locator)
        self.currentViewController = feedViewController
        let navigationController = UINavigationController(rootViewController: feedViewController)
        context.rootViewController = navigationController
    }
    
}
