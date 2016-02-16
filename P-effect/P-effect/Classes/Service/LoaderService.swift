//
//  LoaderService.swift
//  P-effect
//
//  Created by Jack Lapin on 17.01.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

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
    
}


