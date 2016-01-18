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
    
    func showFeedInVC(vc: UIViewController) {
        vc.performSegueWithIdentifier(, sender: nil)
    }
    
//    func showFeed() {
//        let feedStoryboard = UIStoryboard(name: "FeedStoryboard", bundle: nil)
//        let vc = feedStoryboard.instantiateViewControllerWithIdentifier(ViewController.Feed.rawValue) as! FeedVC
//        vc.router = self
//        navigationController.pushViewController(vc, animated: true)
//    }
    
}