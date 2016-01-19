//
//  AuthService.swift
//  P-effect
//
//  Created by anna on 1/18/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class AuthService {
    
    func logIn() {
        PFFacebookUtils.logInInBackgroundWithReadPermissions(["public_profile"]) { user, error in
            if let error = error {
                print("\(error.localizedDescription)")
                return
            }
            if FBSDKAccessToken.currentAccessToken() != nil {
                self.getUserInfo()
            }
        }
    }

    private func getUserInfo() {
        let requestParameters = ["fields": "id, first_name, last_name"]
        let userInfo = FBSDKGraphRequest(graphPath: "me", parameters: requestParameters)
        userInfo.startWithCompletionHandler() { [unowned self] connection, result, error in
            
            if let error = error {
                print("\(error.localizedDescription)")
                return
            }
            
            if let result = result {
                let userId = result["id"] as! String
                let userFirstName = result["first_name"] as? String
                let userLastName = result["last_name"] as? String
                
                var userName = String()
                
                if let userFirstName = userFirstName {
                    userName = userFirstName + " "
                }
                
                if let userLastName = userLastName {
                    userName = userName + userLastName
                }
                self.saveUser(userName, facebookId: userId)
            }
        }
    }
    
    private func saveUser(username: String, facebookId: String) {
        let myUser = User.currentUser()!
        myUser.username = username
        myUser.facebookId = facebookId
        myUser.password = NSUUID().UUIDString
    
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let userProfile = "https://graph.facebook.com/" + facebookId + "/picture?type=large"
            let profilePictureUrl = NSURL(string: userProfile)
            let profilePictureData = NSData(contentsOfURL: profilePictureUrl!)
            
            if let profilePictureData = profilePictureData {
                let profileFileObject = PFFile(data:profilePictureData)
                myUser.avatar = profileFileObject
            }
            myUser.signUpInBackground()
        }
    }
    
    func logOut() {
        User.logOut()
    }
    
}
