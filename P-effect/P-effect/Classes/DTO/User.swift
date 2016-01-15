//
//  User.swift
//  P-effect
//
//  Created by Jack Lapin on 15.01.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class User: PFUser {
    
    @NSManaged var avatar: PFFile?
    @NSManaged var facebookId: String?
    @NSManaged var passwordSet: Bool
    
    override class func initialize(){
        var onceToken : dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    override class func currentUser() -> User? {
        return PFUser.currentUser() as? User
    }
    
    func checkIfUsernameExists(completion:(Bool) -> ())  {
        let query = PFUser.query()?.whereKey("username", equalTo: self.username!)
        query!.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
            if object != nil {
                completion(true)
                print("username exists")
            } else {
                completion(false)
            }
        })
    }
    
    func checkIfFacebookIdExists(completion:(Bool) -> ())  {
        let query = PFUser.query()?.whereKey("facebookId", equalTo: self.facebookId!)
        query!.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
            if object != nil {
                completion(true)
                print("facebookId exists")
            } else {
                completion(false)
            }
        })
    }
    
    func linkOrUnlinkFacebook(completion: (Bool?, NSError?) -> ())  {
        if PFFacebookUtils.isLinkedWithUser(self) {
            PFFacebookUtils.unlinkUserInBackground(self, block: { (success, error) -> Void in
                success ? completion(true, error) : completion(false, error)
            })
        } else {
            PFFacebookUtils.linkUserInBackground(self, withReadPermissions: ["public_profile", "email"], block: { (success, error) -> Void in
                success ? completion(true, error) : completion(false, error)
            })
        }
    }
}
