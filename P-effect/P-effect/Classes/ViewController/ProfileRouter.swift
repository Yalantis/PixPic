//
//  ProfileRouter.swift
//  P-effect
//
//  Created by AndrewPetrov on 2/17/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class ProfileRouter: AlertManagerDelegate, EditProfilePresenter, FeedPresenter, FollowersListPresenter, AuthorizationPresenter {
    
    private var user: User!
    private(set) weak var currentViewController: UIViewController!
    private(set) weak var locator: ServiceLocator!
    
    init(user: User = User.currentUser()!, locator: ServiceLocator) {
        self.user = user
        self.locator = locator
    }
    
}

extension ProfileRouter: Router {
    
    typealias Context = AppearanceNavigationController
    
    func execute(context: AppearanceNavigationController) {
        let profileController = ProfileViewController.create()
        profileController.setRouter(self)
        profileController.setLocator(locator)
        currentViewController = profileController
        profileController.setUser(user)
        context.showViewController(profileController, sender: self)
    }
    
}
