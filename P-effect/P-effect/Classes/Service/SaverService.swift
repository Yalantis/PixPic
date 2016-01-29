//
//  SaverService.swift
//  P-effect
//
//  Created by Jack Lapin on 17.01.16.
//  Copyright © 2016 Jack Lapin. All rights reserved.
//

import Foundation

private let messageDataSuccessfullyUpdated = "User data has been updated!"
private let messageDataNotUpdated = "Some error wile saving! Try again later"
private let messageUsernameCanNotBeEmpty = "User name can not be empty"
private let messageUploadSuccessful = "Upload successful!"


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
    
    class func uploadEffects() {
        
        
        let image = UIImage(named: "delete_50_1")
        let image2 = UIImage(named: "wedding_photo_50")
        let pictureData = UIImageJPEGRepresentation(image!, 0.5)
        let pictureData2 = UIImageJPEGRepresentation(image2!, 0.5)
//        effectsGroup.image = PFFile(name: "image", data: pictureData!)!
        
        let model =  EffectsModel.init()
        var effects = EffectsVersion()
        //        effects.groupsRelation.addObject(model.effectsGroup)
        
        do {
            _ = try effects.save()
        } catch _ {
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            for _ in 0..<3 {
                let effectsGroup = EffectsGroup()
                effectsGroup.image = PFFile(name: "image", data: pictureData2!)!
                do {
                    _ = try effectsGroup.save()
                } catch _ {
                }
                
                for _ in 0..<4 {
                    let effectsSticker = EffectsSticker()
                    effectsSticker.image = PFFile(name: "image", data: pictureData!)!
                    do {
                        _ = try effectsSticker.save()
                    } catch _ {
                    }
                    
                    effectsGroup.stickersRelation.addObject(effectsSticker)
                    do {
                        _ = try effectsGroup.save()
                    } catch _ {
                    }
                }
                
                effects.groupsRelation.addObject(effectsGroup)
                do {
                    _ = try effects.save()
                } catch _ {
                }
            }
            
            effects.saveInBackgroundWithBlock {
                (success: Bool, error: NSError?) -> Void in
                if (success) {
                    effects.groupsRelation.query().findObjectsInBackgroundWithBlock {
                        (objects: [PFObject]?, error: NSError?) -> Void in
                        if let error = error {
                            // There was an error
                        } else {
                            print(objects)
                            // objects has all the Posts the current user liked.
                        }
                    }
                    print(success)
                } else {
                    // There was a problem, check error.description
                }
            }
        }
    }
    
    
    //MARK: - private
    
    private class func uploadEffectsStickers() {
        
    }
    
    private class func uploadEffectsGroup() {
        
    }
    
    
    private class func uploadPost(file: PFFile, comment: String?) {
        if let user = PFUser.currentUser() as? User {
            let post = PostModel(image: file, user: user, comment: comment).post
            post.saveInBackgroundWithBlock{ succeeded, error in
                if succeeded {
                    AlertService.simpleAlert(messageUploadSuccessful)
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
