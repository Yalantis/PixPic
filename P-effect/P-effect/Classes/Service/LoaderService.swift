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
typealias LoadingEffectsCompletion = (objects: [EffectsModel]?, error: NSError?) -> ()


class LoaderService: NSObject {
    
    class func loadEffects(completion: LoadingEffectsCompletion?) {
        var effectsArray = [EffectsModel]()
        var arrayOfStickers = [EffectsSticker]()
        var effectsVersion = EffectsVersion()
        var countOfModels = 0
        var isQueryFromLocalDataStoure = false
        let query = EffectsVersion.query()
        
        ValidationService.needToUpdateVersion { needUpdate in
            if !needUpdate {
                query?.fromLocalDatastore()
                isQueryFromLocalDataStoure = true
            }
            
            query?.getFirstObjectInBackgroundWithBlock { (object: PFObject?, error: NSError?) in
                if let error = error {
                    print("Error: \(error) \(error.userInfo)")
                    completion?(objects: nil, error: error)
                    return
                }
                guard let object = object
                    else {
                        completion?(objects: nil, error: nil)
                        return
                }
                effectsVersion = object as! EffectsVersion
                effectsVersion.saveEventually()
                effectsVersion.pinInBackground()
                let groupsRelationQuery = effectsVersion.groupsRelation.query()
                if isQueryFromLocalDataStoure {
                groupsRelationQuery.fromLocalDatastore()
                }
                groupsRelationQuery.findObjectsInBackgroundWithBlock {
                    (objects:[PFObject]?, error: NSError?) in
                    if  let error = error {
                        print("Error: \(error) \(error.userInfo)")
                        completion?(objects: nil, error: error)
                        return
                    }
                    guard let objects = objects
                        else {
                            completion?(objects: nil, error: nil)
                            return
                    }
                    countOfModels = objects.count
                    for group in objects as! [EffectsGroup] {
                        group.saveEventually()
                        group.pinInBackground()
                        let stickersRelationQuery = group.stickersRelation.query()
                        if isQueryFromLocalDataStoure {
                            stickersRelationQuery.fromLocalDatastore()
                        }
                        stickersRelationQuery.findObjectsInBackgroundWithBlock{
                            (objects:[PFObject]?, error: NSError?) in
                            if let error = error {
                                print("Error: \(error) \(error.userInfo)")
                                completion?(objects: nil, error: error)
                                return
                            }
                            guard let objects = objects
                                else {
                                    completion?(objects: nil, error: nil)
                                    return
                            }
                            arrayOfStickers = objects as! [EffectsSticker]
                            let model = EffectsModel()
                            model.effectsGroup = group
                            model.effectsStickers = arrayOfStickers
                            effectsArray.append(model)
                            for sticker in arrayOfStickers {
                                sticker.saveEventually()
                                sticker.pinInBackground()
                            }
                            if countOfModels == effectsArray.count {
                                completion?(objects: effectsArray, error: nil)
                                return
                            } 
                        }
                    }
                }
            }
        }
    }
    
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
    
    func loadFreshData(user: User?, completion: LoadingPostsCompletion?) {
        let query = Post.query()
        query?.limit = Constants.DataSource.QueryLimit
        load(user, query: query, completion: completion)
    }
    
    func loadPagedData(user: User?, leap: Int, completion: LoadingPostsCompletion?) {
        let query = Post.query()
        query?.limit = Constants.DataSource.QueryLimit
        query?.skip = leap
        load(user, query: query, completion: completion)
    }
    
    private func load(user: User?, query:PFQuery?, completion: LoadingPostsCompletion?) {
        var array = [Post]()
        
        guard let unwrappedUser = PFUser.currentUser()
            else {
                print("No user signUP")
                completion?(objects: nil, error: nil)
                return
        }
        
        let reachability: Reachability
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            print("Unable to create Reachability")
            completion?(objects: nil,error: nil)
            return
        }
        
        if !reachability.isReachable() {
            query?.fromLocalDatastore()
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


