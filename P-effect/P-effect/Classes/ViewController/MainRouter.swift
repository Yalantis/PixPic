//
//  MainRouter.swift
//  P-effect
//
//  Created by AndrewPetrov on 2/17/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class MainRouter {
    
    private(set) weak var currentViewController: UIViewController!
    private weak var window: UIWindow!
    
}

extension MainRouter: Router, FeedPresenter {
    
    func execute(context: UIWindow) {
        window = context
        let feedRouter = FeedRouter()
        feedRouter.execute(window)
    }
    
    func onStart(animated:Bool) {
        if let _ = User.currentUser() {
            execute(window)
            return
        }
        
        AuthService.anonymousLogIn(completion: { [weak self] object in
            guard let this = self else {
                return
            }
            this.execute(this.window)
            }, failure: { error in
                if let error = error {
                    handleError(error)
                }
        })
    }
    
}
