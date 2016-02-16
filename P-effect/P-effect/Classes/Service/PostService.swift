//
//  PostService.swift
//  P-effect
//
//  Created by Jack Lapin on 16.02.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

private let messageUploadSuccessful = "Upload successful!"

typealias LoadingPostsCompletion = (posts: [Post]?, error: NSError?) -> ()

class PostService {
    
    // MARK: - Public methods
    func loadPosts(user: User? = nil, completion: LoadingPostsCompletion) {
        let query = Post.sortedQuery()
        query.limit = Constants.DataSource.QueryLimit
        loadPosts(user, query: query, completion: completion)
    }
    
    func loadPagedData(user: User? = nil, offset: Int = 0, completion: LoadingPostsCompletion) {
        let query = Post.sortedQuery()
        query.limit = Constants.DataSource.QueryLimit
        query.skip = offset
        loadPosts(user, query: query, completion: completion)
    }
    
    func savePost(avatar: PFFile, comment: String? = nil) {
        avatar.saveInBackgroundWithBlock({ succeeded, error in
            if succeeded {
                print("Saved!")
                self.uploadPost(avatar, comment: comment)
            } else if let error = error {
                print(error)
            }
            },
            progressBlock: { percent in
                print("Uploaded: \(percent)%")
            }
        )
    }
    
    // MARK: - Private methods
    private func uploadPost(avatar: PFFile, comment: String?) {
        guard let user = User.currentUser() else {
            // Auth service
            return
        }
        let post = PostModel(image: avatar, user: user, comment: comment).post
        post.saveInBackgroundWithBlock{ succeeded, error in
            if succeeded {
                AlertService.simpleAlert(messageUploadSuccessful)
                NSNotificationCenter.defaultCenter().postNotificationName(
                    Constants.NotificationName.NewPostUploaded,
                    object: nil
                )
            } else {
                if let error = error?.localizedDescription {
                    print(error)
                }
            }
        }
    }
    
    private func loadPosts(user: User?, query: PFQuery, completion: LoadingPostsCompletion) {
        var array = [Post]()
        
        if User.currentUser() == nil {
            print("No user signUP")
            completion(posts: nil, error: nil)
            return
        }
        
        if !ReachabilityHelper.checkConnection() {
            query.fromLocalDatastore()
        }
        
        if let user = user {
            query.whereKey("user", equalTo: user)
        }
        query.findObjectsInBackgroundWithBlock { objects, error -> Void in
            if let objects = objects {
                for object in objects {
                    array.append(object as! Post)
                    object.saveEventually()
                    object.pinInBackground()
                }
                completion(posts: array, error: nil)
            } else if error == nil {
                print("Error: \(error!) \(error!.userInfo)")
                completion(posts: nil, error: error)
            } else {
                completion(posts: nil, error: nil)
            }
        }
    }
    
}