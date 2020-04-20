//
//  LaunchViewController.swift
//  PixPic
//
//  Created by AndrewPetrov on 3/3/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

typealias LaunchRouterInterface = AuthorizationRouterInterface

final class LaunchViewController: UIViewController, StoryboardInitiable {

    static let storyboardName = Constants.Storyboard.launchScreen

    fileprivate var router: LaunchRouterInterface!

    // MARK: - Setup methods
    func setRouter(_ router: LaunchRouterInterface) {
        self.router = router
    }

}

// MARK: - NavigationControllerAppearanceContext methods
extension LaunchViewController: NavigationControllerAppearanceContext {

    func preferredNavigationControllerAppearance(_ navigationController: UINavigationController) -> Appearance? {
        let appearance = Appearance()
        return appearance
    }

}
