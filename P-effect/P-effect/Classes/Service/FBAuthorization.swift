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

class FBAuthorization {
    
    static func signInWithPermission(completion: (User?, ErrorType?) -> ()) {
        let token = FBSDKAccessToken.currentAccessToken()
        PFFacebookUtils.logInInBackgroundWithAccessToken(token) { user, error in
            if let user = user as? User {
                print(PFUser.currentUser() ?? "No user")
                if user.isNew {
                    AuthService.updatePFUserDataFromFB(user) { user, error in
                        completion(user, nil)
                    }
                }
                completion(user, nil)
            } else if let error = error {
                completion(nil, error)
            } else {
                let userError = NSError(
                    domain: NSBundle.mainBundle().bundleIdentifier!,
                    code: 701,
                    userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Facebook error", comment: "")]
                )
                completion(nil, userError)
                return
            }
        }
    }
    
    static func signInWithFacebookInController(controller: UIViewController, completion: (User?, ErrorType?) -> ()) {
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
                AuthService.updatePFUserDataFromFB(user) { user, error in
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