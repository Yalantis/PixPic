//
//  LoaderService.swift
//  P-effect
//
//  Created by Jack Lapin on 17.01.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

typealias LoadingCompletion = (objects: [PEFPost]?, error: NSError?) -> ()

class LoaderService: NSObject {
    
    func deleteObject(object: AnyObject?) -> () {
        
    }
    
    func updateExistingObject(object: AnyObject?) -> () {
        
    }
    
    func loadData(user: User?, completion: LoadingCompletion?) {
        var array = [PEFPost]()
        if User.currentUser() != nil {
            
            let query = PEFPost.query()
            
            let reachability: Reachability
            do {
                reachability = try Reachability.reachabilityForInternetConnection()
            } catch {
                print("Unable to create Reachability")
                return
            }
            
            reachability.whenReachable = { reachability in
                dispatch_async(dispatch_get_main_queue()) {
                    if reachability.isReachableViaWiFi() {
                        print("Reachable via WiFi")
                    } else {
                        print("Reachable via Cellular")
                    }
                }
            }
            reachability.whenUnreachable = { reachability in
                dispatch_async(dispatch_get_main_queue()) {
                    query?.fromLocalDatastore()
                    query?.cachePolicy = PFCachePolicy.CacheThenNetwork
                }
            }
            
            if let user = user, userId = user.facebookId {
                query?.whereKey("facebookId", equalTo: userId)
            }
            
            query?.findObjectsInBackgroundWithBlock {
                (objects:[PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    if let objects = objects {
                        for object in objects {
                            array.append(object as! PEFPost)
                            (object as! PEFPost).saveEventually()
                            (object as! PEFPost).pinInBackground()
                        }
                    }
                    pagination = pagination + 1
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
