//
//  EditProfileRouter.swift
//  P-effect
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
    
    typealias Context = UIViewController
    
    func execute(context: UIViewController) {
        let editProfileController = EditProfileViewController.create()
        editProfileController.setRouter(self)
        editProfileController.setLocator(locator)
        currentViewController = editProfileController
        context.navigationController!.showViewController(editProfileController, sender: self)
    }
    
}
