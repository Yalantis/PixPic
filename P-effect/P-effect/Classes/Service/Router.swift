//
//  Router.swift
//  P-effect
//
//  Created by anna on 1/18/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

private enum ViewController: String {
    case Feed = "FeedViewController"
    case Login = "AuthorizationViewController"
    case Profile = "ProfileViewController"
}

class Router {
    
    private let navigationController: UINavigationController
    
    init(rootViewController: UIViewController) {
        navigationController = UINavigationController(rootViewController: rootViewController)
    }
    
    func showLogin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(ViewController.Login.rawValue)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showFeed() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(ViewController.Feed.rawValue)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showProfile() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewControllerWithIdentifier(ViewController.Profile.rawValue)
        navigationController.pushViewController(vc, animated: true)
    }

}