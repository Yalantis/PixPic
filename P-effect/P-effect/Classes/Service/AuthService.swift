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
                    guard let _ = FBSDKAccessToken.currentAccessToken()
                        else {
                            let userError = NSError(
                                domain: NSBundle.mainBundle().bundleIdentifier!,
                                code: 701,
                                userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Facebook error", comment: "")]
                            )
                            print("Facebook login error.")
                            completion(nil, userError)
                            return
                    }
                    
                    AuthService.updatePFUserDataFromFB(
                        { (user, error) -> () in
                            if let error = error {
                                completion(nil, error)
                            } else {
                                completion(user, nil)
                            }
                        }
                    )
                }
            }
        )
    }
    
    class func updatePFUserDataFromFB(completion: ((User?, NSError?) -> ())?) {
        let user = User.currentUser()!
        let fbRequest = FBSDKGraphRequest(
            graphPath: "me",
            parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"])
        
        fbRequest.startWithCompletionHandler(
            { (FBSDKGraphRequestConnection, result, error) -> () in
                
                if (error == nil && result != nil) {
                    let facebookData = result as! NSDictionary
                    if let avatarURL = NSURL(string: facebookData.objectForKey("picture")?.objectForKey("data")?.objectForKey("url") as! String) {
                        let avatarFile = PFFile(name: Constants.UserKey.Avatar,
                            data: NSData(contentsOfURL: avatarURL)!)
                        user.setValue(avatarFile, forKey: Constants.UserKey.Avatar)
                    }
                    if let email = facebookData["email"] as? String {
                        user.email = email
                    }
                    user.setValue(facebookData.objectForKey("id"), forKey: "facebookId")
                    if let firstname = facebookData.objectForKey("first_name"),
                        lastname = facebookData.objectForKey("last_name") {
                            let nickname: String = String(firstname) + " " + String(lastname)
                            user.setValue(nickname, forKey: "username")
                    }
                    user.saveInBackgroundWithBlock(
                        { (succes, error) -> Void in
                            if let error = error {
                                print(error)
                                completion?(nil, error)
                            } else {
                                completion?(user, nil)
                                print("NEW DATAA FOR OLD USER")
                            }
                        }
                    )
                } else {
                    completion?(nil, error)
                }
            }
        )
    }
    
    
    func anonymousLogIn(completion: (object: User?) -> (), failure: (error: NSError?) -> ()) {
        PFAnonymousUtils.logInWithBlock { user, error in
            if let user = user {
                let userModel = UserModel.init(aUser: user as! User)
                print(User.currentUser())
                completion(object: userModel.user)
            } else {
                print("Anonymous login failed.")
                completion(object: user as? User)
                failure(error: error)
            }
        }
    }
    
    
    func logOut() {
        User.logOut()
    }
    
}
