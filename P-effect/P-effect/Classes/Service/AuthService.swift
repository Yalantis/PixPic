//
//  AuthService.swift
//  P-effect
//
//  Created by anna on 1/18/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class AuthService {
    
    class func signUpWithUser(user: User, completion: (Bool?, NSError?) -> ()) {
        user.signUpInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if let error = error {
                completion (false, error)
            } else {
                user.saveInBackgroundWithBlock(
                    {(success, error) -> Void in
                        if success {
                            completion (true, nil)
                            print("New user saved to parse!")
                        } else {
                            completion (false, nil)
                            print("Failed to save new user to parse.")
                        }
                    }
                )
            }
        }
    }
    
    class func signUpWithFacebookUser(user: User, token: FBSDKAccessToken, completion: (Bool?, NSError?) -> ()) {
        user.password = NSUUID().UUIDString
        self.signUpWithUser(user) { (success, error) -> () in
            if success == true {
                PFFacebookUtils.linkUserInBackground(
                    user, withAccessToken: token, block: {
                        (success, error) -> Void in
                        if success {
                            completion(true, error)
                        } else {
                            completion(false, error)
                        }
                    }
                )
            } else {
                completion(false, error)
            }
        }
    }
    
    
    class func signInWithFacebookInController(controller: UIViewController, completion: (User?, ErrorType?) -> ()) {
        let loginManager = FBSDKLoginManager()
        loginManager.loginBehavior = .Native
        loginManager.logInWithReadPermissions(
            ["public_profile", "email"], fromViewController: controller, handler: {
                (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
                if error != nil {
                    FBSDKLoginManager().logOut()
                    completion(nil, error)
                } else if result.isCancelled {
                    FBSDKLoginManager().logOut()
                    completion(nil, error)
                } else {
                    if let _ = FBSDKAccessToken.currentAccessToken() {
                        let fbRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"])
                        fbRequest.startWithCompletionHandler({ (FBSDKGraphRequestConnection, result, error) -> Void in
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
                                user.setValue(facebookData.objectForKey("id"), forKey: "facebookId")
                                let nickname: String = String(facebookData.objectForKey("first_name")!) + " " + String(facebookData.objectForKey("last_name")!)
                                user.setValue(nickname, forKey: "username")
                                completion (user, nil)
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
    
    
    func anonymousLogIn() {
        PFAnonymousUtils.logInWithBlock { (user: PFUser?, error: NSError?) in
            if error != nil || user == nil {
                print("Anonymous login failed.")
            } else {
                UserModel.init(aUser: user as! User)
                print(User.currentUser())
            }
        }
    }
    
    
    func logOut() {
        User.logOut()
    }
    
}
