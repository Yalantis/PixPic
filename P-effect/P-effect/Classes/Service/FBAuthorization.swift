//
//  fb.swift
//  P-effect
//
//  Created by Jack Lapin on 21.01.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class FBAuthorization {
    
    class func signInWithPermission(completion: (User?, ErrorType?) -> ()) {
        PFFacebookUtils.logInInBackgroundWithAccessToken(
            FBSDKAccessToken.currentAccessToken(),
            block: {
                user, error in
                if let user = user as? User {
                    print(user)
                    print(PFUser.currentUser() ?? "No user")
                    if user.isNew {
                        AuthService.updatePFUserDataFromFB(
                            user,
                            completion: {
                                user, error in
                                completion(user, nil)
                            }
                        )
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
                    print("Facebook login error.")
                    completion(nil, userError)
                    return
                }
            }
        )
    }
    
    class func signInWithFacebookInController(controller: UIViewController, completion: (User?, ErrorType?) -> ()) {
        let loginManager = FBSDKLoginManager()
        loginManager.loginBehavior = .Native
        loginManager.logInWithReadPermissions(
            ["public_profile", "email"],
            fromViewController: controller,
            handler: {
                (result:FBSDKLoginManagerLoginResult!, error:NSError!) in
                if let error = error {
                    FBSDKLoginManager().logOut()
                    completion(nil, error)
                } else if result.isCancelled {
                    FBSDKLoginManager().logOut()
                    completion(nil, error)
                } else {
                    if let _ = FBSDKAccessToken.currentAccessToken() {
                        let fbRequest = FBSDKGraphRequest(
                            graphPath: "me",
                            parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]
                        )
                        fbRequest.startWithCompletionHandler(
                            { FBSDKGraphRequestConnection, result, error in
                                let user = User()
                                if (error == nil && result != nil) {
                                    let facebookData = result as! NSDictionary
                                    if let avatarURL = NSURL(string: facebookData.objectForKey("picture")?.objectForKey("data")?.objectForKey("url") as! String) {
                                        let avatarFile = PFFile(name: "avatar", data: NSData(contentsOfURL: avatarURL)!)
                                        user.setValue(avatarFile, forKey: "avatar")
                                    }
                                    if let email = facebookData.objectForKey("email") as? String {
                                        user.email = email
                                    }
                                    if let firstname = facebookData.objectForKey("first_name"),
                                        lastname = facebookData.objectForKey("last_name") {
                                            let nickname: String = String(firstname) + " " + String(lastname)
                                            user.setValue(nickname, forKey: "username")
                                    }
                                    user.setValue(facebookData.objectForKey("id"), forKey: "facebookId")
                                    completion(user, nil)
                                } else {
                                    completion(user, nil)
                                }
                            }
                        )
                    } else {
                        print("Facebook login error.")
                        completion (nil, nil)
                    }
                }
            }
        )
    }
    
}