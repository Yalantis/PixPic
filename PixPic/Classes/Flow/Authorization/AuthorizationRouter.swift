//
//  AuthorizationRouter.swift
//  PixPic
//
//  Created by AndrewPetrov on 2/17/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class AuthorizationRouter: AlertManagerDelegate, FeedPresenter {
    
    private(set) weak var locator: ServiceLocator!
    private(set) weak var currentViewController: UIViewController!
    
    init(locator: ServiceLocator) {
        self.locator = locator
    }
    
}

extension AuthorizationRouter: Router {
        
    func execute(context: AppearanceNavigationController) {
        let authorizationViewController = AuthorizationViewController.create()
        authorizationViewController.setRouter(self)
        authorizationViewController.setLocator(locator)
        currentViewController = authorizationViewController
        context.pushViewController(authorizationViewController, animated: true)
    }
    
}
