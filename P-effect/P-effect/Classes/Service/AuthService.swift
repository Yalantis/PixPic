//
//  AuthService.swift
//  P-effect
//
//  Created by anna on 1/18/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import ParseFacebookUtilsV4

class AuthService {
    
    class func updatePFUserDataFromFB(user: User, completion: ((User?, NSError?) -> ())?) {
        let fbRequest = FBSDKGraphRequest(
            graphPath: "me",
            parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"])
        fbRequest.startWithCompletionHandler( { FBSDKGraphRequestConnection, result, error in
                if (error == nil && result != nil) {
                    let facebookData = result as! NSDictionary
                    if let avatarURL = NSURL(string: facebookData.objectForKey("picture")?.objectForKey("data")?.objectForKey("url") as! String) {
                        let avatarFile = PFFile(
                            name: Constants.UserKey.Avatar,
                            data: NSData(contentsOfURL: avatarURL)!
                        )
                        user.avatar = avatarFile
                    }
                    if let email = facebookData["email"] as? String {
                        user.email = email
                    }
                    user.facebookId = facebookData.objectForKey("id") as? String
                    if let firstname = facebookData.objectForKey("first_name"),
                        lastname = facebookData.objectForKey("last_name") {
                            let nickname: String = String(firstname) + " " + String(lastname)
                            user.username = nickname
                    }
                    user.saveInBackgroundWithBlock(
                        { succes, error in
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
    
    static func anonymousLogIn(completion completion: (object: User?) -> (), failure: (error: NSError?) -> ()) {
        PFAnonymousUtils.logInWithBlock { user, error in
            if let error = error {
                failure(error: error)
            } else if let user = user as? User{
                completion(object: user)
                PFInstallation.addPFUserToCurrentInstallation()
            }
        }
    }
    
    static func logOut() {
        PFFacebookUtils.unlinkUserInBackground(User.currentUser()!)
        User.logOut()
        FBSDKLoginManager().logOut()
    }
    
}
