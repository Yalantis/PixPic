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
        AuthService.signInWithFacebookInController(
            self, completion: {
                (user, error) -> () in
                if let user = user as User! {
                    let user = UserModel.init(aUser: user)
                    
                    user.checkIfFacebookIdExists({ [unowned self] exists in
                        if !exists {
                            PFFacebookUtils.logInInBackgroundWithAccessToken(
                                FBSDKAccessToken.currentAccessToken(), block: {
                                    ( user: PFUser?, error:NSError?) -> () in
                                    self.view.hideToastActivity()
            
                                    PFFacebookUtils.logInInBackgroundWithAccessToken(FBSDKAccessToken.currentAccessToken())
                                    let currentUser = UserModel.init(aUser: User.currentUser()!)
                                    currentUser.linkOrUnlinkFacebook(
                                        { (success, error) -> () in
                                            if let error = error {
                                                print(error)
                                            } else {
                                                print("LINKED!!! NEED TO UPDATE DATA")
                                                AuthService.updatePFUserDataFromFB(nil)
                                            }
                                        }
                                    )
                                    Router.sharedRouter().showHome(animated: true)
                                }
                            )
                            
                        } else {
                            user.checkIfUsernameExists({ (exists) -> () in
                                if exists {
                                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
                                    controller.model = ProfileViewModel.init(profileUser: user.user)
                                    self.navigationController?.showViewController(controller, sender: self)
                                    print("Username is already taken!")
                                } else {
                                    if user.user.facebookId != nil  {
                                        user.user.passwordSet = false
                                        let token = FBSDKAccessToken.currentAccessToken()
                                        AuthService.signUpWithFacebookUser(
                                            user.user, token: token, completion: {
                                                (success, error) -> () in
                                                print("\(error)")
                                                if success == true {
                                                    Router.sharedRouter().showHome(animated: true)
                                                } else {
                                                    handleError(error!)
                                                }
                                            }
                                        )
                                    } else {
                                        user.user.passwordSet = true
                                        AuthService.signUpWithUser(user.user) { (success, error) -> () in
                                            if success == true {
                                                Router.sharedRouter().showHome(animated: true)
                                            } else {
                                                handleError(error!)
                                            }
                                        }
                                    }
                                }
                                }
                            )
                        }
                        }
                    )
                }
                print("connectWithFacebookAction called")
            }
        )
    }
    
    @IBAction func withoutLoginButtonTapped(sender: AnyObject) {
        AuthService().anonymousLogIn()
    }
}