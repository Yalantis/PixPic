//
//  EffectsService.swift
//  P-effect
//
//  Created by anna on 2/16/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

typealias LoadingEffectsCompletion = (objects: [EffectsModel]?, error: NSError?) -> Void

class EffectsService {
    
    func loadEffects(completion: LoadingEffectsCompletion) {
        var effectsArray = [EffectsModel]()
        var arrayOfStickers = [EffectsSticker]()
        var effectsVersion = EffectsVersion()
        var countOfModels = 0
        var isQueryFromLocalDataStoure = false
        let query = EffectsVersion.query()
        
        needToUpdateVersion { needUpdate in
            if !needUpdate {
                query?.fromLocalDatastore()
                isQueryFromLocalDataStoure = true
            }
            
            query?.getFirstObjectInBackgroundWithBlock { object, error in
                if let error = error {
                    print("Error: \(error) \(error.userInfo)")
                    completion(objects: nil, error: error)
                    return
                }
                guard let object = object else {
                    completion(objects: nil, error: nil)
                    return
                }
                effectsVersion = object as! EffectsVersion
                effectsVersion.saveEventually()
                effectsVersion.pinInBackground()
                let groupsRelationQuery = effectsVersion.groupsRelation.query()
                if isQueryFromLocalDataStoure {
                    groupsRelationQuery.fromLocalDatastore()
                }
                groupsRelationQuery.findObjectsInBackgroundWithBlock { objects, error in
                    if let error = error {
                        print("Error: \(error) \(error.userInfo)")
                        completion(objects: nil, error: error)
                        return
                    }
                    guard let objects = objects else {
                        completion(objects: nil, error: nil)
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
                        stickersRelationQuery.findObjectsInBackgroundWithBlock{ objects, error in
                            if let error = error {
                                print("Error: \(error) \(error.userInfo)")
                                completion(objects: nil, error: error)
                                return
                            }
                            guard let objects = objects else {
                                completion(objects: nil, error: nil)
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
                                completion(objects: effectsArray, error: nil)
                                return
                            }
                        }
                    }
                }
            }
        }
    }
    
    func needToUpdateVersion(completion: Bool -> Void) {
        var effectsVersion = EffectsVersion()
        let query = EffectsVersion.query()
        let queryFromLocal = EffectsVersion.query()
        queryFromLocal?.fromLocalDatastore()
        
        guard ReachabilityHelper.checkConnection() else {
            completion(false)
            return
        }
        query?.getFirstObjectInBackgroundWithBlock { object, error in
            if let error = error {
                print("Error: \(error) \(error.userInfo)")
                completion(false)
                return
            } else if let object = object {
                effectsVersion = object as! EffectsVersion
                queryFromLocal?.getFirstObjectInBackgroundWithBlock { localObject, error in
                    if let error = error {
                        print("Error: \(error) \(error.userInfo)")
                        completion(true)
                        return
                    } else if let localObject = localObject {
                        if effectsVersion.version > (localObject as! EffectsVersion).version {
                            completion(true)
                        } else {
                            completion (false)
                        }
                    }
                }
            }
        }
    }

}
