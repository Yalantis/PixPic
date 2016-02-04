//
//  UserModel.swift
//  P-effect
//
//  Created by Jack Lapin on 15.01.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class UserModel: NSObject {
    
    var user: User
    
    init(aUser: User) {
        user = aUser
        super.init()
    }
    
    func checkIfUsernameExists(completion:(Bool) -> ()) {
        let query = PFUser.query()?.whereKey("username", equalTo: user.username!)
        query?.getFirstObjectInBackgroundWithBlock(
            { object, error in
                if object != nil {
                    completion(true)
                    print("username exists")
                } else {
                    completion(false)
                }
            }
        )
    }
    
    func checkIfFacebookIdExists(completion:(Bool) -> ()) {
        let query = User.query()?.whereKey("facebookId", equalTo: user.facebookId!)
        query?.getFirstObjectInBackgroundWithBlock(
            { object, error in
                if object != nil {
                    completion(true)
                    print("facebookId exists")
                } else {
                    completion(false)
                }
            }
        )
    }
    
    func linkIfUnlinkFacebook(completion: (NSError?) -> ()) {
        if PFFacebookUtils.isLinkedWithUser(user) {
            completion(nil)
        } else {
            PFFacebookUtils.linkUserInBackground(
                user,
                withReadPermissions: ["public_profile", "email"],
                block: {
                    success, error in
                    success ? completion(nil) : completion(error)
                }
            )
        }
    }
    
}

