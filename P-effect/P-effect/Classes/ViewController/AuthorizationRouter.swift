//
//  AuthorizationRouter.swift
//  P-effect
//
//  Created by AndrewPetrov on 2/17/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class AuthorizationRouter: AlertServiceDelegate {
    
    private(set) weak var currentViewController: UIViewController!
    
}

extension AuthorizationRouter: FeedPresenter {
    
    typealias Context = UIViewController
    
    func execute(context: UIViewController) {
        let authorizationViewController = AuthorizationViewController.create()
        authorizationViewController.router = self
        currentViewController = authorizationViewController
        context.navigationController!.pushViewController(authorizationViewController, animated: true)
    }
    
}
