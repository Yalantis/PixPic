//
//  FeedRouter.swift
//  P-effect
//
//  Created by AndrewPetrov on 2/17/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class FeedRouter: Router, AlertManagerDelegate {
    
    weak var locator: ServiceLocator!
    
    private(set) weak var currentViewController: UIViewController!
    
}

extension FeedRouter: ProfilePresenter, PhotoEditorPresenter, AuthorizationPresenter, FeedPresenter {
    
    typealias Context = UIWindow
    
    func execute(context: UIWindow) {
        locator = ServiceLocator()
        locator.registerService(PostService())
        locator.registerService(EffectsService())
        locator.registerService(UserService())
        locator.registerService(ValidationService())
        locator.registerService(AuthService())
        locator.registerService(ImageLoaderService())
        
        if User.currentUser() == nil {
            (locator.getService() as AuthService).anonymousLogIn(
                completion: { _ in
                },
                failure: { error in
                    if let error = error {
                        handleError(error)
                    }
            })
        }
        let feedViewController = FeedViewController.create()
        feedViewController.router = self
        feedViewController.locator = locator
        currentViewController = feedViewController
        let navigationController = UINavigationController(rootViewController: feedViewController)
        context.rootViewController = navigationController
    }
    
}
