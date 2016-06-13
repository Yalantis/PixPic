//
//  LaunchRouter.swift
//  PixPic
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
        locator.registerService(StickersLoaderService())
        locator.registerService(UserService())
        locator.registerService(ValidationService())
        locator.registerService(AuthenticationService())
        locator.registerService(ComplaintService())
        locator.registerService(ActivityService())
    }
}

extension LaunchRouter: Router {
        
    func execute(context: UIWindow) {
        let launchViewController = LaunchViewController.create()
        launchViewController.setRouter(self)
        currentViewController = launchViewController
        let navigationController = AppearanceNavigationController(rootViewController: launchViewController)
        context.rootViewController = navigationController
        
        if User.isAbsent {
            let authenticationService: AuthenticationService = locator.getService()
            authenticationService.anonymousLogIn(
                completion: { [weak self] _ in
                    self?.presentFeed(context)
                },
                failure: { error in
                    if let error = error {
                        ErrorHandler.handle(error)
                    }
            })
        } else {
            presentFeed(context)
        }
    }
    
    private func presentFeed(context: UIWindow) {
        let feedRouter = FeedRouter(locator: locator)
        feedRouter.execute(context)
    }
    
}
