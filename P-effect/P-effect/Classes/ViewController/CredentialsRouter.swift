//
//  CredentialsRouter.swift
//  P-effect
//
//  Created by AndrewPetrov on 3/1/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class CredentialsRouter: AlertManagerDelegate, SettingsPresenter {
    
    private(set) weak var currentViewController: UIViewController!
    private(set) weak var locator: ServiceLocator!
    
    init(locator: ServiceLocator) {
        self.locator = locator
    }
    
}

extension CredentialsRouter: Router {
    
    typealias Context = UINavigationController
    
    func execute(context: UINavigationController) {
        let credentialsController = CredentialsViewController.create()
        credentialsController.router = self
        credentialsController.setLocator(locator)
        currentViewController = credentialsController
        context.showViewController(credentialsController, sender: self)
    }
    
}

