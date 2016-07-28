//
//  User.swift
//  PixPic
//
//  Created by Jack Lapin on 15.01.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import ParseFacebookUtilsV4

class User: PFUser {
    
    @NSManaged var avatar: PFFile?
    @NSManaged var facebookId: String?
    @NSManaged var appUsername: String?
    @NSManaged var passwordSet: Bool
    
    private static var onceToken: dispatch_once_t = 0
    
    static var sortedQuery: PFQuery {
        let query = PFQuery(className: User.parseClassName())
        query.orderByDescending("updatedAt")
        
        return query
    }
    
    override class func initialize() {
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    override class func currentUser() -> User? {
        return PFUser.currentUser() as? User
    }
    
}

extension User {
    
    var isCurrentUser: Bool {
        get {
            if let currentUser = User.currentUser() where currentUser.facebookId == self.facebookId {
                return true
            }
            
            return false
        }
    }
    
    static var isAbsent: Bool {
        get {
            return User.currentUser() == nil
        }
    }
    
    static var notAuthorized: Bool {
        get {
            return PFAnonymousUtils.isLinkedWithUser(User.currentUser()) || User.isAbsent
        }
    }

}
