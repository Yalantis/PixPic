//
//  SaverService.swift
//  P-effect
//
//  Created by Jack Lapin on 17.01.16.
//  Copyright © 2016 Jack Lapin. All rights reserved.
//

import Foundation

class SaverService {
    
    //MARK: - public
    
    func saveAndUploadPost(file: PFFile, comment: String?) {
        file.saveInBackgroundWithBlock(
            { (succeeded, error) -> () in
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
                { (succeeded, error) -> () in
                    if succeeded {
                        print("Avatar saved!")
                        SaverService.uploadUserChanges(user, avatar: avatar, nickname: nickname, completion: nil)
                    } else if let error = error {
                        print(error)
                    }
                }, progressBlock: { percent in
                    print("Uploaded: \(percent)%")
                }
            )
        }
    }
    
    //MARK: - private
    
    class func uploadPost(file: PFFile, comment: String?) {
        if let user = PFUser.currentUser() as? User {
            let post = PostModel(image: file, user: user, comment: comment).post
            post.saveInBackgroundWithBlock{ succeeded, error in
                if succeeded {
                    AlertService.simpleAlert("Upload successful!")
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
    
    class func uploadUserChanges(user: User, avatar: PFFile, nickname: String?, completion: ((Bool?, String?) -> ())?) {
        user.avatar = avatar
        if let nickname = nickname {
            user.username = nickname
            user.saveInBackgroundWithBlock{ succeeded, error in
                if succeeded {
                    completion?(true, nil)
                    AlertService.simpleAlert("User data has been updated!")
                    
                } else {
                    AlertService.simpleAlert("Some error wile saving! Try gain later")
                    if let error = error?.userInfo["error"] as? String {
                        print(error)
                        completion?(false, error)
                    }
                }
            }
        } else {
            completion?(false, "User name can not be empty")
        }
    }
}
