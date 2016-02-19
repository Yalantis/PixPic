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
    
    private var isQueryFromLocalDataStoure = false
    
    func loadEffects(completion: LoadingEffectsCompletion) {
        let query = EffectsVersion.sortedQuery
        var effectsVersion = EffectsVersion()
        
        needToUpdateVersion { [weak self] needUpdate in
            guard let this = self else {
                return
            }
            if !needUpdate {
                query.fromLocalDatastore()
                this.isQueryFromLocalDataStoure = true
            }

            query.getFirstObjectInBackgroundWithBlock { object, error in
                if let error = error {
                    print(error.localizedDescription)
                    completion(objects: nil, error: error)
                    return
                }
                
                guard let object = object as? EffectsVersion  else {
                    completion(objects: nil, error: nil)
                    return
                }
                
                effectsVersion = object
                effectsVersion.pinInBackground()
                
                this.loadEffectsGroups(effectsVersion) { objects, error in
                    completion(objects: objects, error: error)
                }
            }
        }
    }
    
    private func loadEffectsGroups(effectsVersion: EffectsVersion, completion: LoadingEffectsCompletion) {
        let groupsRelationQuery = effectsVersion.groupsRelation.query()
        
        if isQueryFromLocalDataStoure {
            groupsRelationQuery.fromLocalDatastore()
        }
        
        groupsRelationQuery.findObjectsInBackgroundWithBlock { [weak self] objects, error in
            if let error = error {
                print(error.localizedDescription)
                completion(objects: nil, error: error)
                return
            }
            
            guard let objects = objects as? [EffectsGroup] else {
                completion(objects: nil, error: nil)
                return
            }
            
            self?.loadEffectsStickers(objects) { objects, error in
                completion(objects: objects, error: error)
            }
        }
    }
    
    private func loadEffectsStickers(effectsGroups: [EffectsGroup], completion: LoadingEffectsCompletion) {
        var effects = [EffectsModel]()
        var stickers = [EffectsSticker]()
        let groupsQuantity = effectsGroups.count
        
        for group in effectsGroups {
            group.pinInBackground()

            let stickersRelationQuery = group.stickersRelation.query()
            if isQueryFromLocalDataStoure {
                stickersRelationQuery.fromLocalDatastore()
            }
            stickersRelationQuery.findObjectsInBackgroundWithBlock { objects, error in
                if let error = error {
                    print(error.localizedDescription)
                    completion(objects: nil, error: error)
                    return
                }
                
                guard let objects = objects as? [EffectsSticker] else {
                    completion(objects: nil, error: nil)
                    return
                }
                
                stickers = objects
                let effect = EffectsModel(effectsGroup: group, effectsStickers: stickers)
                effects.append(effect)
                
                for sticker in stickers {
                    sticker.pinInBackground()
                }
                
                if groupsQuantity == effects.count {
                    completion(objects: effects, error: nil)
                    return
                }
            }
        }
    }

    private func needToUpdateVersion(completion: Bool -> Void) {
        var effectsVersion = EffectsVersion()
        let query = EffectsVersion.sortedQuery
        let queryFromLocal = EffectsVersion.sortedQuery
        queryFromLocal.fromLocalDatastore()
        
        guard ReachabilityHelper.checkConnection() else {
            completion(false)
            return
        }
        
        query.getFirstObjectInBackgroundWithBlock { object, error in
            if let error = error {
                print(error.localizedDescription)
                completion(false)
                return
            }
            
            guard let object = object as? EffectsVersion else {
                return
            }
            
            effectsVersion = object
            queryFromLocal.getFirstObjectInBackgroundWithBlock { localObject, error in
                if let error = error {
                    print(error.localizedDescription)
                    completion(true)
                    return
                }
                
                guard let localObject = localObject as? EffectsVersion else {
                    return
                }
                
                if effectsVersion.version > localObject.version {
                    completion(true)
                } else {
                    completion (false)
                }
            }
        }
    }

}
