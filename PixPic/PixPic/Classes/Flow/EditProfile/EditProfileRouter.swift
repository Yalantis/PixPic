//
//  EditProfileRouter.swift
//  PixPic
//
//  Created by AndrewPetrov on 2/17/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class EditProfileRouter: AlertManagerDelegate, FeedPresenter {
    
    private var user: User!
    private(set) weak var locator: ServiceLocator!
    private(set) weak var currentViewController: UIViewController!
    
    init(user: User = User.currentUser()!, locator: ServiceLocator) {
        self.user = user
        self.locator = locator
    }
    
}

extension EditProfileRouter: Router {
        
    func execute(context: AppearanceNavigationController) {
        let editProfileController = EditProfileViewController.create()
        editProfileController.setRouter(self)
        editProfileController.setLocator(locator)
        currentViewController = editProfileController
        context.showViewController(editProfileController, sender: self)
    }
    
}
