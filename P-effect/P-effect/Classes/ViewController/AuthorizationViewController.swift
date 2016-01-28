//
//  AuthorizationViewController.swift
//  P-effect
//
//  Created by anna on 1/16/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class AuthorizationViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction private func logInWithFBButtonTapped() {
        view.makeToastActivity(CSToastPositionCenter)
        signInWithFacebook()
    }
    
    private func signInWithFacebook() {
        FBAuthorization.signInWithFacebookInController(self, completion: { [weak self] user, error in
            if let error = error {
                handleError(error as NSError)
            }
            if let user = user as User! {
                UserModel.init(aUser: user).checkIfFacebookIdExists({ exists in
                    if exists {
                        user.passwordSet = false
                        self?.signIn()
                    } else {
                        self?.logIn()
                    }
                })
                } else {
                    self?.proceedWithoutAuthorization()
                }
            })
    }
    
    private func proceedWithoutAuthorization() {
        Router.sharedRouter().showHome(animated: true)
        let reachability: Reachability
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            print("Unable to create Reachability")
            return
        }
        
        if !reachability.isReachable() {
            let message = reachability.currentReachabilityStatus.description
            AlertService.simpleAlert(message)
        }
    }
    
    private func signIn() {
        FBAuthorization.signInWithPermission({ [weak self] user, error in
            if let error = error {
                handleError(error as NSError)
            } else if let user = user {
                print("SIGNING INN!!!  with ", user.username)
                let installation = PFInstallation.currentInstallation()
                installation["user"] = PFUser.currentUser()
                installation.saveInBackground()
                Router.sharedRouter().showHome(animated: true)
            } else {
                print("unknown trouble while signing IN")
            }
            self?.view.hideToastActivity()
        })
    }
    
    private func logIn() {
        PFFacebookUtils.logInInBackgroundWithAccessToken(
            FBSDKAccessToken.currentAccessToken(), block: { [weak self] user, error in
                let user = UserModel.init(aUser: User.currentUser()!)
                user.linkOrUnlinkFacebook({ success, error in
                    if let error = error {
                        handleError(error)
                    } else {
                        print("LINKED!!! NEED TO UPDATE DATA")
                        AuthService.updatePFUserDataFromFB(user.user, completion: { user, error in
                            if let error = error {
                                handleError(error)
                            } else if let _ = user {
                                print("User has been updated")
                            }
                        })
                    }
                })
                self?.view.hideToastActivity()
                Router.sharedRouter().showHome(animated: true)
        })

    }
    
}