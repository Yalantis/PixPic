//
//  Router.swift
//  P-effect
//
//  Created by anna on 1/18/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

private let appRouterAnimationDelay = 0.3
private let appRouterAnimationDuration = 0.45

private enum ViewControllerIDs: String {
    case Feed = "FeedViewController"
    case Login = "AuthorizationViewController"
    case Profile = "ProfileViewController"
}

class Router {
    
    private static var router: Router?
    private static var routerOnceToken: dispatch_once_t = 0
    
    class func sharedRouter() -> Router {
        dispatch_once(&routerOnceToken) {
            router = Router()
        }
        return router!
    }
    
    func onStart(animated:Bool) {
        if let _ = PFUser.currentUser() {
            showHome(animated: true)
            return
        }
        // hidden login anonumous user
        showLogin(animated: false)
    }
    
    func showLogin(animated animated:Bool) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let controllerIdentifier = ViewControllerIDs.Login.rawValue
        let viewController = mainStoryboard.instantiateViewControllerWithIdentifier(controllerIdentifier) as! AuthorizationViewController
        if let viewController: UIViewController = UINavigationController.init(rootViewController: viewController) {
            show(viewController, animated: animated)
        }
    }
    
    func showHome(animated animated:Bool) {
        let board = UIStoryboard(name: "Main", bundle: nil)
        let controllerIdentifier = ViewControllerIDs.Feed.rawValue
        let viewController = board.instantiateViewControllerWithIdentifier(controllerIdentifier)
        show(viewController, animated: animated)
    }
    
    func show(viewController:UIViewController?, animated:Bool) {
        switchRootToViewController(viewController)
    }
    
    // MARK: - Private
    
    private func switchRootToViewController(viewController: UIViewController?) {
        if let window = UIApplication.sharedApplication().delegate!.window! as UIWindow! {
            window.rootViewController = viewController
        }
    }

}