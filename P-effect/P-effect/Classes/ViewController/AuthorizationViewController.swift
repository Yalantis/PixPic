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
            completion: {
                [weak self] user, error in
                if let error = error {
                    handleError(error as NSError)
                }
                if let user = user as User! {
                    UserModel.init(aUser: user).checkIfFacebookIdExists(
                        { exists in
                            if exists {
                                user.passwordSet = false
                                self?.signIn(user)
                            } else {
                                self?.signUp(user)
                            }
                        }
                    )
                } else {
                    self?.proceedWithoutAuthorization()
                }
            }
        )
    }
    
    private func proceedWithoutAuthorization() {
        Router.sharedRouter().showHome(animated: true)
        ReachabilityHelper.isInternetAccessAvailable()
    }
    
    private func signUp(user: User) {
        let userWithFB = user
        FBAuthorization.signInWithPermission(
            { [weak self] user, error in
                if let error = error {
                    handleError(error as NSError)
                } else if let user = user {
                    let user = UserModel.init(aUser: user)
                    user.user.facebookId = userWithFB.facebookId
                    user.user.username = userWithFB.username
                    user.user.email = userWithFB.email
                    user.user.avatar = userWithFB.avatar
                    user.user.saveInBackgroundWithBlock(
                        { succes, error in
                            if let error = error {
                                print(error)
                            } else {
                                print("NEW DATAA FOR LINKED USER")
                                let installation = PFInstallation.currentInstallation()
                                installation["user"] = user.user
                                installation.saveInBackground()
                            }
                        }
                    )
                    print("SIGNING UP!!!  with ", user.user.username)
                    Router.sharedRouter().showHome(animated: true)
                } else {
                    print("unknown trouble while signing IN")
                }
                self?.view.hideToastActivity()
            }
        )
    }
    
    private func signIn(user: User) {
        let token = FBSDKAccessToken.currentAccessToken()
        PFFacebookUtils.logInInBackgroundWithAccessToken(
            token,
            block: {
                [weak self] user, error in
                if let error = error {
                    handleError(error)
                } else {
                    let user = UserModel.init(aUser: user as! User)
                    user.linkIfUnlinkFacebook(
                        { error in
                            if let error = error {
                                handleError(error)
                            } else {
                                print("already linked!")
                                let installation = PFInstallation.currentInstallation()
                                installation["user"] = user.user
                                installation.saveInBackground()
                            }
                        }
                    )
                }
                self?.view.hideToastActivity()
                Router.sharedRouter().showHome(animated: true)
            }
        )
    }
    
}