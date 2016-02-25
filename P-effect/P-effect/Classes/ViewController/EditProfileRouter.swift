//
//  EditProfileRouter.swift
//  P-effect
//
//  Created by AndrewPetrov on 2/17/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class EditProfileRouter: AlertServiceDelegate {
    
    weak var locator: ServiceLocator!
    
    private(set) weak var currentViewController: UIViewController!
    private var user: User!
    
    init(user: User = User.currentUser()!) {
        self.user = user
    }
    
}

extension EditProfileRouter: FeedPresenter {
    typealias Context = UIViewController
    
    func execute(context: UIViewController) {
        let editProfileController = EditProfileViewController.create()
        editProfileController.router = self
        editProfileController.locator = locator
        currentViewController = editProfileController
        context.navigationController!.showViewController(editProfileController, sender: self)
    }
    
}
