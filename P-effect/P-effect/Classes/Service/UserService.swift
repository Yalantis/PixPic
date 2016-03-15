//
//  UserService.swift
//  P-effect
//
//  Created by Jack Lapin on 16.02.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

typealias LoadingUserCompletion = (object: User?, error: NSError?) -> Void

private let messageDataSuccessfullyUpdated = "User data has been updated!"
private let messageDataNotUpdated = "Troubles with the update! Check it out later"

class UserService {
    
    func uploadUserChanges(user: User, avatar: PFFile, nickname: String, completion: (Bool?, String?) -> Void) {
        user.avatar = avatar
        user.username = nickname
        user.saveInBackgroundWithBlock { succeeded, error in
            if succeeded {
                completion(true, nil)
                AlertManager.sharedInstance.showSimpleAlert(messageDataSuccessfullyUpdated)
            } else {
                AlertManager.sharedInstance.showSimpleAlert(messageDataNotUpdated)
                if let error = error?.localizedDescription {
                    completion(false, error)
                }
            }
        }
    }
    
    func fetchUser(userId: String, completion: ((user: User?, error: NSError?) -> Void)?) {
        let query = User.sortedQuery()
        query.whereKey(Constants.UserKey.Id, equalTo: userId)
        query.findObjectsInBackgroundWithBlock { objects, error in
            if let error = error {
                completion?(user: nil, error: error)
            } else if let user = objects?.first as? User {
                completion?(user: user, error: nil)
            }
        }
    }
    
}
