//
//  fb.swift
//  P-effect
//
//  Created by Jack Lapin on 21.01.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation
import Parse
import ParseFacebookUtilsV4

enum AuthError: Int {
    
    case FacebookError = 701
    
}

class FBAuthorization {
    
    static func signInWithPermission(completion: (User?, NSError?) -> Void) {
        let token = FBSDKAccessToken.currentAccessToken()
        PFFacebookUtils.logInInBackgroundWithAccessToken(token) { user, error in
            if let user = user as? User {
                print(User.currentUser() ?? "No user")
                if user.isNew {
                    AuthService.updateUserInfoViaFacebook(user) { user, error in
                        completion(user, nil)
                    }
                }
                completion(user, nil)
            } else if let error = error {
                completion(nil, error)
            } else {
                let userError = NSError.createAuthError(.FacebookError)
                completion(nil, userError)
                return
            }
        }
    }
    
    static func signInWithFacebookInController(controller: UIViewController, completion: (User?, ErrorType?) -> Void) {
        let loginManager = FBSDKLoginManager()
        let permissions = ["public_profile", "email"]
        
        loginManager.loginBehavior = .Native
        loginManager.logInWithReadPermissions(permissions, fromViewController: controller) { result, error in
            if let error = error {
                FBSDKLoginManager().logOut()
                completion(nil, error)
            } else if result.isCancelled {
                FBSDKLoginManager().logOut()
                completion(nil, error)
            } else {
                let user = User()
                AuthService.updateUserInfoViaFacebook(user) { user, error in
                    if let error = error {
                        completion(nil, error)
                    } else {
                        completion(user, nil)
                    }
                }
            }
        }
    }
    
}