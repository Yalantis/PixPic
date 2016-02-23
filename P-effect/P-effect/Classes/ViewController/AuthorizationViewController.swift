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

final class AuthorizationViewController: UIViewController, StoryboardInitable {
    
    internal static let storyboardName = Constants.Storyboard.Authorization
    
    var router: AuthorizationRouter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        AlertService.sharedInstance.delegate = router
    }
    
    @IBAction private func logInWithFBButtonTapped() {
        view.makeToastActivity(CSToastPositionCenter)
        signInWithFacebook()
    }
    
    private func signInWithFacebook() {
        FBAuthorization.signInWithFacebookInController(self) { [weak self] user, error in
            if let error = error {
                handleError(error as NSError)
            }
            guard let user = user as User? else {
                if let this = self {
                    this.proceedWithoutAuthorization()
                }
                return
            }
            user.checkFacebookIdExistance { exists in
                guard let this = self else {
                    return
                }
                if exists {
                    user.passwordSet = false
                    this.signIn(user)
                } else {
                    this.signUp(user)
                    
                }
            }
        }
    }
    
    private func proceedWithoutAuthorization() {
        router.showFeed()
        ReachabilityHelper.checkConnection()
    }
    
    private func signUp(user: User) {
        let userWithFB = user
        FBAuthorization.signInWithPermission { [weak self] user, error in
            if let error = error {
                handleError(error as NSError)
            }
            guard let this = self else {
                return
            }
            guard let user = user else {
                this.view.hideToastActivity()
                print("unknown trouble while signing IN")
                return
            }
            user.facebookId = userWithFB.facebookId
            user.username = userWithFB.username
            user.email = userWithFB.email
            user.avatar = userWithFB.avatar
            user.saveInBackgroundWithBlock { _, error in
                if let error = error {
                    print(error)
                } else {
                    let installation = PFInstallation.currentInstallation()
                    installation["user"] = user
                    installation.saveInBackground()
                }
            }
            print("SIGNING UP!!!  with ", user.username)
            this.view.hideToastActivity()
            this.router.showFeed()
        }
    }
    
    private func signIn(user: User) {
        let token = FBSDKAccessToken.currentAccessToken()
        PFFacebookUtils.logInInBackgroundWithAccessToken(token) { [weak self] user, error in
            if error != nil {
                ExceptionHandler.handle(Exception.InvalidSessionToken)
            }
            guard let this = self else {
                return
            }
            guard let user = user as? User else {
                this.view.hideToastActivity()
                this.router.showFeed()
                
                return
            }
            
            user.linkWithFacebook { error in
                if let error = error {
                    handleError(error)
                } else {
                    guard let this = self else {
                        return
                    }
                    print("linked!")
                    let installation = PFInstallation.currentInstallation()
                    installation["user"] = user
                    installation.saveInBackground()
                    this.view.hideToastActivity()
                    this.router.showFeed()
                }
            }
            user.saveEventually()
        }
    }
    
}