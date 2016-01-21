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
        AuthService.signInWithFacebookInController(
            self, completion: {
                [weak self](user, error) -> () in
                if let user = user as User! {
                    let user = UserModel.init(aUser: user)
                    user.checkIfFacebookIdExists({ (exists) -> () in
                        if exists {
                            // need progress here
                            PFFacebookUtils.logInInBackgroundWithAccessToken(
                                FBSDKAccessToken.currentAccessToken(), block: {
                                    (user: PFUser?, error:NSError?) -> Void in
                                    //need stop progress here
                                    PFFacebookUtils.logInInBackgroundWithAccessToken(FBSDKAccessToken.currentAccessToken())
                                    Router.sharedRouter().showHome(animated: true)
                                }
                            )
                            
                        } else {
                            user.checkIfUsernameExists({ (exists) -> () in
                                if exists {
                                    let controller = self?.storyboard!.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
                                    controller.model = ProfileViewModel.init(profileUser: user.user)
                                    self?.navigationController?.pushViewController(controller, animated: true)
                                    print("Username is already taken!")
                                } else {
                                    if user.user.facebookId != nil  {
                                        user.user.passwordSet = false
                                        let token = FBSDKAccessToken.currentAccessToken()
                                        AuthService.signUpWithFacebookUser(
                                            user.user, token: token, completion: {
                                                (success, error) -> () in
                                                if success == true {
                                                    Router.sharedRouter().showHome(animated: true)
                                                } else {
                                                    // handle error
                                                }
                                            }
                                        )
                                    } else {
                                        user.user.passwordSet = true
                                        AuthService.signUpWithUser(user.user) { (success, error) -> () in
                                            if success == true {
                                                Router.sharedRouter().showHome(animated: true)
                                            } else {
                                                // handle error
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
    
}