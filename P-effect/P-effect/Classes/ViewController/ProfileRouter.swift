//
//  ProfileRouter.swift
//  P-effect
//
//  Created by AndrewPetrov on 2/17/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class ProfileRouter: AlertServiceDelegate {
    
    private(set) weak var currentViewController: UIViewController!
    private var user: User!
    
    convenience init(user: User = User.currentUser()!, currentViewController: UIViewController) {
        self.init(user: user)
        
        self.currentViewController = currentViewController
    }
    
    init(user: User = User.currentUser()!) {
        self.user = user
    }
    
}

extension ProfileRouter: EditProfilePresenter, FeedPresenter {
    typealias Context = UIViewController
    
    func execute(context: UIViewController) {
        let profileController = ProfileViewController.create()
        profileController.router = self
        currentViewController = profileController
        profileController.model = ProfileViewModel(profileUser: user)
        context.navigationController!.showViewController(profileController, sender: self)
    }
    
}
