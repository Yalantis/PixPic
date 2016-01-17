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
    
    func uploadObject(object: AnyObject?) -> () {
        
    }
    
    func deleteObject(object: AnyObject?) -> () {
        
    }
    
    func updateExistingObject(object: AnyObject?) -> () {
        
    }
    
    func loadData(completion: LoadingCompletion?) {
        var array = [PEFPost]()
        if User.currentUser() != nil {
            let query = PEFPost.query()
            query?.findObjectsInBackgroundWithBlock {
                (objects:[PFObject]?, error: NSError?) -> Void in
                if error == nil {
                    if let objects = objects {
                        for object in objects {
                            array.append(object as! PEFPost)
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
