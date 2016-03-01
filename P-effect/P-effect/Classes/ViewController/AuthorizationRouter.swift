//
//  AuthorizationRouter.swift
//  P-effect
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
    
    typealias Context = UIViewController
    
    func execute(context: UIViewController) {
        let authorizationViewController = AuthorizationViewController.create()
        authorizationViewController.router = self
        authorizationViewController.setLocator(locator)
        currentViewController = authorizationViewController
        context.navigationController!.pushViewController(authorizationViewController, animated: true)
    }
    
}
