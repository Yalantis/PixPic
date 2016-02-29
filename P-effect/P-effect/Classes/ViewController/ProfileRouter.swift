//
//  ProfileRouter.swift
//  P-effect
//
//  Created by AndrewPetrov on 2/17/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class ProfileRouter: AlertManagerDelegate {
    
    weak var locator: ServiceLocator!
    
    private(set) weak var currentViewController: UIViewController!
    private var user: User!
    
    init(user: User = User.currentUser()!) {
        self.user = user
    }
    
}

extension ProfileRouter: EditProfilePresenter, FeedPresenter {
    typealias Context = UIViewController
    
    func execute(context: UIViewController) {
        let profileController = ProfileViewController.create()
        profileController.router = self
        profileController.locator = locator
        currentViewController = profileController
        profileController.user = user
        context.navigationController!.showViewController(profileController, sender: self)
    }
    
}
