//
//  FollowersListRouter.swift
//  P-effect
//
//  Created by anna on 3/3/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class FollowersListRouter: AlertManagerDelegate, ProfilePresenter {
    
    private var user: User!
    private(set) weak var locator: ServiceLocator!
    private(set) weak var currentViewController: UIViewController!
    
    init(user: User = User.currentUser()!, locator: ServiceLocator) {
        self.user = user
        self.locator = locator
    }
    
}

extension FollowersListRouter: Router {
    
    typealias Context = UIViewController
    
    func execute(context: UIViewController) {
        let editProfileController = FollowersViewController.create()
        editProfileController.router = self
        editProfileController.setLocator(locator)
        currentViewController = editProfileController
        context.navigationController!.showViewController(editProfileController, sender: self)
    }
    
}
