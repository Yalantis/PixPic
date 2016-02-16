//
//  PostService.swift
//  P-effect
//
//  Created by Jack Lapin on 16.02.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

private let messageUploadSuccessful = "Upload successful!"

//typealias LoadingPostsCompletion = (objects: [Post]?, error: NSError?) -> ()


class PostService {
    
    //MARK: - public
    func loadFreshData(user: User? = nil, completion: LoadingPostsCompletion?) {
        let query = Post.query()
        query?.limit = Constants.DataSource.QueryLimit
        load(user, query: query, completion: completion)
    }
    
    func loadPagedData(user: User? = nil, leap: Int, completion: LoadingPostsCompletion?) {
        let query = Post.query()
        query?.limit = Constants.DataSource.QueryLimit
        query?.skip = leap
        load(user, query: query, completion: completion)
    }
    
    func saveAndUploadPost(file: PFFile, comment: String? = nil) {
        file.saveInBackgroundWithBlock(
            { succeeded, error in
                if succeeded {
                    print("Saved!")
                    self.uploadPost(file, comment: comment)
                } else if let error = error {
                    print(error)
                }
            }, progressBlock: { percent in
                print("Uploaded: \(percent)%")
            }
        )
    }
    
    //MARK: - private
    private func uploadPost(file: PFFile, comment: String?) {
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
    
    private func load(user: User?, query:PFQuery?, completion: LoadingPostsCompletion?) {
        var array = [Post]()
        
        guard let _ = PFUser.currentUser()
            else {
                print("No user signUP")
                completion?(objects: nil, error: nil)
                return
        }
        guard ReachabilityHelper.checkConnection() else {
            completion?(objects: nil,error: nil)
            
            return
        }
        if let user = user {
            query?.whereKey("user", equalTo: user)
        }
        
        query?.findObjectsInBackgroundWithBlock {
            (objects:[PFObject]?, error: NSError?) -> Void in
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        array.append(object as! Post)
                        (object as! Post).saveEventually()
                        (object as! Post).pinInBackground()
                    }
                }
                completion?(objects: array, error: nil)
            } else {
                print("Error: \(error!) \(error!.userInfo)")
                completion?(objects: nil, error: error)
            }
        }
    }
    
}