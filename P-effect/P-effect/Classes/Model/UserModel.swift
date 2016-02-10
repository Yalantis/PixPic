//
//  UserModel.swift
//  P-effect
//
//  Created by Jack Lapin on 15.01.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import ParseFacebookUtilsV4


class UserModel: NSObject {
    
    var user: User
    
    init(aUser: User) {
        user = aUser
        super.init()
    }
    
    func checkIfUsernameExists(completion: Bool -> Void) {
        guard let username = user.username,
            query = PFUser.query()?.whereKey("username", equalTo: username) else {
            completion(false)
            return
        }
        query.getFirstObjectInBackgroundWithBlock(
            { object, _ in
                if object != nil {
                    completion(true)
                    print("username exists")
                } else {
                    completion(false)
                }
            }
        )
    }
    
    func checkIfFacebookIdExists(completion: Bool -> Void) {
        guard let facebookId = user.facebookId,
            query = User.query()?.whereKey("facebookId", equalTo: facebookId) else {
            completion(false)
            return
        }
        query.getFirstObjectInBackgroundWithBlock(
            { object, _ in
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

