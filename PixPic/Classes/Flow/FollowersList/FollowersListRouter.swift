//
//  FollowersListRouter.swift
//  PixPic
//
//  Created by anna on 3/3/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class FollowersListRouter: AlertManagerDelegate, ProfilePresenter {

    fileprivate var user: User!
    fileprivate let followType: FollowType!
    fileprivate(set) weak var locator: ServiceLocator!
    fileprivate(set) weak var currentViewController: UIViewController!

    init(user: User = User.currentUser()!, followType: FollowType, locator: ServiceLocator) {
        self.user = user
        self.followType = followType
        self.locator = locator
    }

}

extension FollowersListRouter: Router {

    func execute(_ context: AppearanceNavigationController) {
        execute(context, userInfo: nil)
    }

    func execute(_ context: AppearanceNavigationController, userInfo: AnyObject?) {
        let followersController = FollowersListViewController.create()
        followersController.setRouter(self)
        followersController.setLocator(locator)
        currentViewController = followersController
        followersController.setUser(user)
        followersController.setFollowType(followType)
        context.show(followersController, sender: self)
    }

}
