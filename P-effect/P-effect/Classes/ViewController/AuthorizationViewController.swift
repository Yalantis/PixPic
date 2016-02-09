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
        FBAuthorization.signInWithFacebookInController(
            self,
            completion: { [weak self] user, error in
                if let error = error {
                    handleError(error as NSError)
                }
                guard let user = user as User? else {
                    self?.proceedWithoutAuthorization()
                    return
                }
                UserModel(aUser: user).checkIfFacebookIdExists { exists in
                    if exists {
                        user.passwordSet = false
                        self?.signIn(user)
                    } else {
                        self?.signUp(user)
                    }
                }
            }
        )
    }
    
    private func proceedWithoutAuthorization() {
        Router.sharedRouter().showHome(animated: true)
        ReachabilityHelper.checkConnection()
    }
    
    private func signUp(user: User) {
        let userWithFB = user
        FBAuthorization.signInWithPermission(
            { [weak self] user, error in
                if let error = error {
                    handleError(error as NSError)
                }
                guard let user = user else {
                    self?.view.hideToastActivity()
                    print("unknown trouble while signing IN")
                    return
                }
                let userModel = UserModel(aUser: user)
                userModel.user.facebookId = userWithFB.facebookId
                userModel.user.username = userWithFB.username
                userModel.user.email = userWithFB.email
                userModel.user.avatar = userWithFB.avatar
                userModel.user.saveInBackgroundWithBlock { _, error in
                    if let error = error {
                        print(error)
                    } else {
                        print("NEW DATAA FOR LINKED USER")
                        let installation = PFInstallation.currentInstallation()
                        installation["user"] = userModel.user
                        installation.saveInBackground()
                    }
                }
                print("SIGNING UP!!!  with ", userModel.user.username)
                self?.view.hideToastActivity()
                Router.sharedRouter().showHome(animated: true)
            }
        )
    }
    
    private func signIn(user: User) {
        let token = FBSDKAccessToken.currentAccessToken()
        PFFacebookUtils.logInInBackgroundWithAccessToken(
            token,
            block: {
                [weak self] user, error in
                if let _ = error {
                    ExceptionHandler.handle(Exception.InvalidSessionToken)
                }
                guard let user = user as? User else {
                    self?.view.hideToastActivity()
                    Router.sharedRouter().showHome(animated: true)
                    return
                }
                let userModel = UserModel(aUser: user)
                userModel.linkIfUnlinkFacebook { error in
                    if let error = error {
                        handleError(error)
                    } else {
                        print("already linked!")
                        let installation = PFInstallation.currentInstallation()
                        installation["user"] = userModel.user
                        installation.saveInBackground()
                        self?.view.hideToastActivity()
                        Router.sharedRouter().showHome(animated: true)
                    }
                }
            }
        )
    }
    
}