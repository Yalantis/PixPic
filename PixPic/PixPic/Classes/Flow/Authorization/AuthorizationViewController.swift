//
//  AuthorizationViewController.swift
//  PixPic
//
//  Created by anna on 1/16/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import Toast
import ParseFacebookUtilsV4

typealias AuthorizationRouterInterface = protocol<FeedPresenter, AlertManagerDelegate>

final class AuthorizationViewController: UIViewController, StoryboardInitiable {
    
    static let storyboardName = Constants.Storyboard.Authorization
    
    private var router: AuthorizationRouterInterface!
    private weak var locator: ServiceLocator!
    
    // MARK: - Lifecycle
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        AlertManager.sharedInstance.setAlertDelegate(router)
    }
    
    // MARK: - Setup methods
    func setLocator(locator: ServiceLocator) {
        self.locator = locator
    }
    
    func setRouter(router: AuthorizationRouterInterface) {
        self.router = router
    }
    
    // MARK: - Private methods
    private func signInWithFacebook() {
        let authenticationService: AuthenticationService = locator.getService()
        authenticationService.signInWithFacebookInController(self) { [weak self] _, error in
            if let error = error {
                ErrorHandler.handle(error)
                self?.proceedWithoutAuthorization()
            } else {
                authenticationService.signInWithPermission { _, error -> Void in
                    if let error = error {
                        ErrorHandler.handle(error)
                    } else {
                        PFInstallation.addPFUserToCurrentInstallation()
                    }
                }
                self?.view.hideToastActivity()
                self?.router.showFeed()
            }
        }
    }
    
    private func proceedWithoutAuthorization() {
        router.showFeed()
        guard ReachabilityHelper.isReachable() else {
            ExceptionHandler.handle(Exception.NoConnection)
            
            return
        }
    }
    
    // MARK: - IBAction
    @IBAction private func logInWithFBButtonTapped() {
        view.makeToastActivity(CSToastPositionCenter)
        signInWithFacebook()
    }
    
}

extension AuthorizationViewController: NavigationControllerAppearanceContext {
    
    func preferredNavigationControllerAppearance(navigationController: UINavigationController) -> Appearance? {
        var appearance = Appearance()
        appearance.title = Constants.Profile.NavigationTitle
        return appearance
    }
    
}
