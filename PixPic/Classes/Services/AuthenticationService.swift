//
//  AuthenticationService.swift
//  PixPic
//
//  Created by anna on 1/18/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation
import Parse
import ParseFacebookUtilsV4

enum AuthenticationError: Int {
    case FacebookError = 701
    case ParseError = 702
    case ParseCurrentUserNotExist = 703
    case InvalidAccessToken = 704
}

class AuthenticationService {
    
    func signInWithPermission(completion: (User!, NSError?) -> Void) {
        guard let token = FBSDKAccessToken.currentAccessToken() else {
            let accessTokenError = NSError.authenticationError(.InvalidAccessToken)
            completion(nil, accessTokenError)
            
            return
        }
        PFFacebookUtils.logInInBackgroundWithAccessToken(token) { [weak self] user, error in
            if let user = user as? User {
                if user.isNew {
                    self?.updateUserInfoViaFacebook(user) { user, error in
                        completion(user, nil)
                    }
                } else {
                    completion(user, nil)
                }
            } else if let error = error {
                completion(nil, error)
            } else {
                let userError = NSError.authenticationError(.FacebookError)
                completion(nil, userError)
                
                return
            }
        }
    }
    
    func signInWithFacebookInController(controller: UIViewController, completion: (FBSDKLoginManagerLoginResult?, NSError?) -> Void) {
        let loginManager = FBSDKLoginManager()
        let permissions = ["public_profile", "email", "user_photos"]
        
        loginManager.loginBehavior = .Native
        loginManager.logInWithReadPermissions(permissions, fromViewController: controller) { result, error in
            if error != nil || result.isCancelled {
                loginManager.logOut()
                completion(nil, error)
            } else {
                completion(result, nil)
            }
        }
    }
    
    func updateUserInfoViaFacebook(user: User, completion: (User?, NSError?) -> Void) {
        let parameters = ["fields": "id, name, first_name, last_name, picture.type(large), email"]
        let fbRequest = FBSDKGraphRequest(
            graphPath: "me",
            parameters: parameters
        )
        fbRequest.startWithCompletionHandler { _, result, error in
            if error == nil && result != nil {
                guard let facebookInfo = result as? [String: AnyObject],
                    picture = facebookInfo["picture"] as? [String: AnyObject],
                    data = picture["data"] as? [String: AnyObject],
                    url = data["url"] as? String else {
                        completion(nil, nil)
                        
                        return
                }
                if let avatarURL = NSURL(string: url) {
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
                if let firstname = facebookInfo["first_name"] as? String,
                    lastname = facebookInfo["last_name"] as? String {
                        user.username = "\(firstname) \(lastname)"
                }
                completion(user, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    
    func anonymousLogIn(completion completion: (object: User?) -> Void, failure: (error: NSError?) -> Void) {
        PFAnonymousUtils.logInWithBlock { user, error in
            if let error = error {
                failure(error: error)
            } else if let user = user as? User {
                completion(object: user)
                PFInstallation.addPFUserToCurrentInstallation()
            }
        }
    }
    
    func logOut() {
        User.logOut()
        FBSDKLoginManager().logOut()
    }
    
}
