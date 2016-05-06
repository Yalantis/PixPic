//
//  LaunchViewController.swift
//  P-effect
//
//  Created by AndrewPetrov on 3/3/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

typealias LaunchRouterInterface = AuthorizationRouterInterface

final class LaunchViewController: UIViewController, StoryboardInitable {
    
    static let storyboardName = Constants.Storyboard.LaunchScreen
    
    private var router: LaunchRouterInterface!
    
    // MARK: - Setup methods
    func setRouter(router: LaunchRouterInterface) {
        self.router = router
    }

}
