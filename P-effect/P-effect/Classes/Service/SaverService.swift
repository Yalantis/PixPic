//
//  SaverService.swift
//  P-effect
//
//  Created by Jack Lapin on 17.01.16.
//  Copyright © 2016 Jack Lapin. All rights reserved.
//

import Foundation

private let messageDataSuccessfullyUpdated = "User data has been updated!"
private let messageDataNotUpdated = "Troubles with the update! Check it out later"
private let messageUsernameCanNotBeEmpty = "User name can not be empty"
private let messageUploadSuccessful = "Upload successful!"


class SaverService {
    
    //MARK: - public
    
    func saveAndUploadPost(file: PFFile, comment: String?) {
        file.saveInBackgroundWithBlock(
            { succeeded, error in
                if succeeded {
                    print("Saved!")
                    SaverService.uploadPost(file, comment: comment)
                } else if let error = error {
                    print(error)
                }
            }, progressBlock: { percent in
                print("Uploaded: \(percent)%")
            }
        )
    }
    
    
    func saveAndUploadUserData(user: User, avatar: PFFile?, nickname: String?) {
        if let avatar = avatar {
            avatar.saveInBackgroundWithBlock(
                { succeeded, error in
                    if succeeded {
                        print("Avatar saved!")
                        SaverService.uploadUserChanges(user, avatar: avatar, nickname: nickname)
                    } else if let error = error {
                        print(error)
                    }
                }, progressBlock: { percent in
                    print("Uploaded: \(percent)%")
                }
            )
        }
    }
    
    class func uploadUserChanges(user: User, avatar: PFFile, nickname: String?, completion: ((Bool?, String?) -> ())? = nil) {
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
    
    //MARK: - private
    
    private class func uploadPost(file: PFFile, comment: String?) {
        if let user = PFUser.currentUser() as? User {
            let post = PostModel(image: file, user: user, comment: comment).post
            post.saveInBackgroundWithBlock{ succeeded, error in
                if succeeded {
                    AlertService.simpleAlert(messageUploadSuccessful)
                    NSNotificationCenter.defaultCenter().postNotificationName(
                        Constants.NotificationKey.NewPostUploaded,
                        object: nil
                    )
                } else {
                    if let error = error?.userInfo["error"] as? String {
                        print(error)
                    }
                }
            }
        } else {
            // Auth service
        }
    }
    
}
