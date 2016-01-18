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
    case Profile = ""
}

class Router {
    
    private let navigationController: UINavigationController
    
    init(root: UIViewController) {
        navigationController = UINavigationController(rootViewController: root)
    }
    
    func showLogin() {
        let vc = navigationController.storyboard?.instantiateViewControllerWithIdentifier(ViewController.Login.rawValue) as! AuthorizationViewController
        navigationController.pushViewController(vc, animated: true)
    }
    
    func showFeed() {
        let vc = navigationController.storyboard?.instantiateViewControllerWithIdentifier(ViewController.Feed.rawValue)
        navigationController.pushViewController(vc!, animated: true)
    }
    
}