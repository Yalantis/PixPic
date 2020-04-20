//
//  EditProfileRouter.swift
//  PixPic
//
//  Created by AndrewPetrov on 2/17/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class EditProfileRouter: AlertManagerDelegate, FeedPresenter {

    fileprivate var user: User!
    fileprivate(set) weak var locator: ServiceLocator!
    fileprivate(set) weak var currentViewController: UIViewController!

    init(user: User = User.currentUser()!, locator: ServiceLocator) {
        self.user = user
        self.locator = locator
    }

}

extension EditProfileRouter: Router {

    func execute(_ context: AppearanceNavigationController) {
        execute(context, userInfo: nil)
    }

    func execute(_ context: AppearanceNavigationController, userInfo: AnyObject?) {
        let editProfileController = EditProfileViewController.create()
        editProfileController.setRouter(self)
        editProfileController.setLocator(locator)
        currentViewController = editProfileController
        context.showViewController(editProfileController, sender: self)
    }

}
