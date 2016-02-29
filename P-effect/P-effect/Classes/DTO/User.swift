//
//  User.swift
//  P-effect
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
    
    override class func initialize() {
        var onceToken: dispatch_once_t = 0;
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    override class func currentUser() -> User? {
        return PFUser.currentUser() as? User
    }
    
    static func sortedQuery() -> PFQuery {
        let query = PFQuery(className: User.parseClassName())
        query.orderByDescending("updatedAt")
        return query
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
    
    func checkUsernameExistance(completion: Bool -> Void) {
        guard let username = username else {
            completion(false)
            return
        }
        let query = User.sortedQuery().whereKey("username", equalTo: username)
        query.getFirstObjectInBackgroundWithBlock { object, _ in
            if object != nil {
                completion(true)
                print("username exists")
            } else {
                completion(false)
            }
        }
    }
    
    // MARK: - ProfileViewControllerMethods
    func loadUserAvatar(completion: LoadingImageCompletion) {
        if let avatar = avatar {
            ImageLoaderService.getImageForContentItem(avatar) { image, error in
                completion(image: image, error: error)
            }
        }
    }

}


