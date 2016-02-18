//
//  EditProfileRouter.swift
//  P-effect
//
//  Created by AndrewPetrov on 2/17/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class EditProfileRouter {
    
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

extension EditProfileRouter: FeedPresenter {
    typealias Context = UIViewController
    
    func execute(context: UIViewController) {
        
        let editProfileController = EditProfileViewController.create()
        editProfileController.router = self
        currentViewController = editProfileController
        context.navigationController!.showViewController(editProfileController, sender: self)
    }
    
}
