//
//  FollowersListRouter.swift
//  PixPic
//
//  Created by anna on 3/3/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class FollowersListRouter: AlertManagerDelegate, ProfilePresenter {
    
    private var user: User!
    private let followType: FollowType!
    private(set) weak var locator: ServiceLocator!
    private(set) weak var currentViewController: UIViewController!
    
    init(user: User = User.currentUser()!, followType: FollowType, locator: ServiceLocator) {
        self.user = user
        self.followType = followType
        self.locator = locator
    }
    
}

extension FollowersListRouter: Router {
        
    func execute(context: AppearanceNavigationController) {
        let followersController = FollowersListViewController.create()
        followersController.setRouter(self)
        followersController.setLocator(locator)
        currentViewController = followersController
        followersController.setUser(user)
        followersController.setFollowType(followType)
        context.showViewController(followersController, sender: self)
    }
    
}
