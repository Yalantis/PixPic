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
        guard let username = user.username else {
            completion(false)
            return
        }
        let query = User.sortedQuery().whereKey("username", equalTo: username)
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
        guard let facebookId = user.facebookId else {
            completion(false)
            return
        }
        let query = User.sortedQuery().whereKey("facebookId", equalTo: facebookId)
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

