//
//  UserService.swift
//  P-effect
//
//  Created by Jack Lapin on 16.02.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

private let messageDataSuccessfullyUpdated = "User data has been updated!"
private let messageDataNotUpdated = "Troubles with the update! Check it out later"
private let messageUsernameCanNotBeEmpty = "User name can not be empty"

class UserService {
    
    func saveAndUploadUserData(user: User, avatar: PFFile?, nickname: String?) {
        if let avatar = avatar {
            avatar.saveInBackgroundWithBlock(
                { succeeded, error in
                    if succeeded {
                        print("Avatar saved!")
                        self.uploadUserChanges(user, avatar: avatar, nickname: nickname)
                    } else if let error = error {
                        print(error)
                    }
                }, progressBlock: { percent in
                    print("Uploaded: \(percent)%")
                }
            )
        }
    }
    
    func uploadUserChanges(user: User, avatar: PFFile, nickname: String?, completion: ((Bool?, String?) -> ())? = nil) {
        user.avatar = avatar
        if let nickname = nickname {
            user.username = nickname
            user.saveInBackgroundWithBlock {
                succeeded, error in
                if succeeded {
                    completion?(true, nil)
                    AlertService.simpleAlert(messageDataSuccessfullyUpdated)
                } else {
                    AlertService.simpleAlert(messageDataNotUpdated)
                    if let error = error?.userInfo["error"] as? String {
                        print(error)
                        completion?(false, error)
                    }
                }
            }
        } else {
            completion?(false, messageUsernameCanNotBeEmpty)
        }
    }
}
