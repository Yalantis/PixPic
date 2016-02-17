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
    
    static func updatePFUserDataFromFB(user: User, completion: (User?, NSError?) -> ()) {
        let fbRequest = FBSDKGraphRequest(
            graphPath: "me",
            parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]
        )
        fbRequest.startWithCompletionHandler { _, result, error in
            if error == nil && result != nil {
                guard let facebookInfo = result as? Dictionary<String, AnyObject>,
                    let picture = facebookInfo["picture"],
                    let data = picture["data"],
                    let URL = data!["url"] as? String else {
                        completion(nil, nil)
                        return
                }
                if let avatarURL = NSURL(string: URL) {
                    let avatarFile = PFFile(
                        name: Constants.UserKey.Avatar,
                        data: NSData(contentsOfURL: avatarURL)!
                    )
                    user.avatar = avatarFile
                }
                if let email = facebookInfo["email"] as? String {
                    user.email = email
                }
                user.facebookId = facebookInfo["id"] as? String
                if let firstname = facebookInfo["first_name"],
                    lastname = facebookInfo["last_name"] {
                        let nickname: String = String(firstname) + " " + String(lastname)
                        user.username = nickname
                }
                completion(user, nil)
            } else {
                completion(nil, error)
            }
        }
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
