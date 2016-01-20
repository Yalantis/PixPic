//
//  LoaderService.swift
//  P-effect
//
//  Created by Jack Lapin on 17.01.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

typealias LoadingPostsCompletion = (objects: [Post]?, error: NSError?) -> ()
typealias LoadingUserCompletion = (object: User?, error: NSError?) -> ()


class LoaderService: NSObject {
    
    func loadUserData(facebookId: String?, completion: LoadingUserCompletion?) {
        var user = User()
        if let facebookId = facebookId {
            let query = User.query()
            query?.whereKey("facebookId", equalTo: facebookId)
            query?.findObjectsInBackgroundWithBlock {
                (objects:[PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    if let objects = objects {
                        user = objects.first as! User
                    }
                    completion?(object: user, error: nil)
                } else {
                    print("Error: \(error!) \(error!.userInfo)")
                    completion?(object: nil, error: error)
                }
            }
        }  else {
            print("No facebookId to find a User")
            completion?(object: nil, error: nil)
        }
    }
    
    func loadData(user: User?, completion: LoadingPostsCompletion?) {
        var array = [Post]()
        if PFUser.currentUser() != nil {
            
            let query = Post.query()
            
            let reachability: Reachability
            do {
                reachability = try Reachability.reachabilityForInternetConnection()
            } catch {
                print("Unable to create Reachability")
                return
            }
            
            if !reachability.isReachable() {
                query?.fromLocalDatastore()
            }
            
            if let user = user, userId = user.facebookId {
                query?.whereKey("facebookId", equalTo: userId)
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
        } else {
            print("No user signUP")
            completion?(objects: nil, error: nil)
        }
    }

}
