//
//  ProfileRouter.swift
//  PixPic
//
//  Created by AndrewPetrov on 2/17/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class ProfileRouter: AlertManagerDelegate, EditProfilePresenter, FeedPresenter, FollowersListPresenter, AuthorizationPresenter {

    private var user: User?
    private var userId: String?
    private(set) weak var currentViewController: UIViewController!
    private(set) weak var locator: ServiceLocator!

    init(user: User = User.currentUser()!, locator: ServiceLocator) {
        self.user = user
        self.locator = locator
    }

    init(userId: String, locator: ServiceLocator) {
        self.userId = userId
        self.locator = locator
    }

}

extension ProfileRouter: Router {

    func execute(context: AppearanceNavigationController) {
        execute(context, userInfo: nil)
    }

    func execute(context: AppearanceNavigationController, userInfo: AnyObject?) {
        let profileController = ProfileViewController.create()
        profileController.setRouter(self)
        profileController.setLocator(locator)
        currentViewController = profileController
        if let userInfo = userInfo {
            profileController.setUserInfo(userInfo)
        }
        if let user = user {
            profileController.user = user
        } else if let userId = userId {
            profileController.setUserId(userId)
        }
        context.showViewController(profileController, sender: self)
    }

}
