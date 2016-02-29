//
//  AuthorizationViewController.swift
//  P-effect
//
//  Created by anna on 1/16/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import Toast
import ParseFacebookUtilsV4

class AuthorizationViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction private func logInWithFBButtonTapped() {
        view.makeToastActivity(CSToastPositionCenter)
        signInWithFacebook()
    }
    
    private func signInWithFacebook() {
        AuthService.signInWithFacebookInController(self) { [weak self] _, error in
            if let error = error {
                handleError(error)
                self?.proceedWithoutAuthorization()
            } else {
                AuthService.signInWithPermission { _, error -> Void in
                    if let error = error {
                        handleError(error)
                    } else {
                        PFInstallation.addPFUserToCurrentInstallation()
                    }
                }
                self?.view.hideToastActivity()
                Router().showHome(animated: true)
            }
        }
    }
    
    private func proceedWithoutAuthorization() {
        Router.sharedRouter().showHome(animated: true)
        ReachabilityHelper.checkConnection()
    }
    
}