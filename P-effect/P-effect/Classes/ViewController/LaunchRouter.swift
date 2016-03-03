//
//  LaunchRouter.swift
//  P-effect
//
//  Created by AndrewPetrov on 3/3/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class LaunchRouter: AlertManagerDelegate, FeedPresenter {
    
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

extension LaunchRouter: Router {
    
    typealias Context = UIWindow
    
    func execute(context: UIWindow) {
        let launchViewController = LaunchViewController.create()
        launchViewController.router = self
        self.currentViewController = launchViewController
        let navigationController = UINavigationController(rootViewController: launchViewController)
        context.rootViewController = navigationController
        
        let feedRouter = FeedRouter(locator: locator)
        if User.currentUser() == nil {
            (locator.getService() as AuthService).anonymousLogIn(
                completion: { _  in
                    feedRouter.execute(context)
                },
                failure: { error in
                    if let error = error {
                        handleError(error)
                    }
            })
        } else {
            feedRouter.execute(context)
        }
    }
    
}
