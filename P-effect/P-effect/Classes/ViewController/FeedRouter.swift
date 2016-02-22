//
//  FeedRouter.swift
//  P-effect
//
//  Created by AndrewPetrov on 2/17/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class FeedRouter: Router, AlertServiceDelegate {
    
    lazy var locator = ServiceLocator()
    
    private(set) weak var currentViewController: UIViewController!
    
}

extension FeedRouter: ProfilePresenter, PhotoEditorPresenter, AuthorizationPresenter, FeedPresenter {
    typealias Context = UIWindow
    
    func execute(context: UIWindow) {
        locator.registerService(PostService())
        
        let feedViewController = FeedViewController.create()
        feedViewController.router = self
        currentViewController = feedViewController
        let navigationController = UINavigationController(rootViewController: feedViewController)
        context.rootViewController = navigationController
    }
    
}
