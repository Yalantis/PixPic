//
//  AuthService.swift
//  P-effect
//
//  Created by anna on 1/18/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class AuthService {
    
    class func signInWithFacebookInController(
        controller: UIViewController,
        completion: (User?, ErrorType?) -> ()) {
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
                        completion(nil, error)
                    }
                }
            )
    }
    
    class func updatePFUserDataFromFB(user: User, completion: ((User?, NSError?) -> ())?) {
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
        if PFFacebookUtils.isLinkedWithUser(User.currentUser()!) {
            PFFacebookUtils.unlinkUserInBackground(
                User.currentUser()!,
                block: {
                    (success, error) -> () in
                    print("ss")
                }
            )
        }
        User.logOut()
    }
    
}
