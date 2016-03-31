//
//  EffectsService.swift
//  P-effect
//
//  Created by anna on 2/16/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

typealias LoadingStickersCompletion = (objects: [StickersModel]?, error: NSError?) -> Void

class StickersLoaderService {
    
    private var isQueryFromLocalDataStoure = false
    
    func loadStickers(completion: LoadingStickersCompletion) {
        let query = StickersVersion.sortedQuery
        var stickersVersion = StickersVersion()
        
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
                    log.debug(error.localizedDescription)
                    completion(objects: nil, error: error)
                    
                    return
                }
                
                guard let object = object as? StickersVersion  else {
                    completion(objects: nil, error: nil)
                    
                    return
                }
                
                stickersVersion = object
                stickersVersion.pinInBackground()
                
                this.loadStickersGroups(stickersVersion) { objects, error in
                    completion(objects: objects, error: error)
                }
            }
        }
    }
    
    private func loadStickersGroups(stickersVersion: StickersVersion, completion: LoadingStickersCompletion) {
        let groupsRelationQuery = stickersVersion.groupsRelation.query()
        
        if isQueryFromLocalDataStoure {
            groupsRelationQuery.fromLocalDatastore()
        }
        
        groupsRelationQuery.findObjectsInBackgroundWithBlock { [weak self] objects, error in
            if let error = error {
                log.debug(error.localizedDescription)
                completion(objects: nil, error: error)
                
                return
            }
            
            guard let objects = objects as? [StickersGroup] else {
                completion(objects: nil, error: nil)
                
                return
            }
            
            self?.loadAllStickers(objects) { objects, error in
                completion(objects: objects, error: error)
            }
        }
    }
    
    private func loadAllStickers(stickersGroups: [StickersGroup], completion: LoadingStickersCompletion) {
        var stickersModels = [StickersModel]()
        var stickers = [Sticker]()
        let groupsQuantity = stickersGroups.count
        
        for group in stickersGroups {
            group.pinInBackground()

            let stickersRelationQuery = group.stickersRelation.query()
            if isQueryFromLocalDataStoure {
                stickersRelationQuery.fromLocalDatastore()
            }
            stickersRelationQuery.findObjectsInBackgroundWithBlock { objects, error in
                if let error = error {
                    log.debug(error.localizedDescription)
                    completion(objects: nil, error: error)
                    
                    return
                }
                
                guard let objects = objects as? [Sticker] else {
                    completion(objects: nil, error: nil)
                    
                    return
                }
                
                stickers = objects
                let model = StickersModel(stickersGroup: group, stickers: stickers)
                stickersModels.append(model)
                
                for sticker in stickers {
                    sticker.pinInBackground()
                }
                
                if groupsQuantity == stickersModels.count {
                    completion(objects: stickersModels, error: nil)
                    
                    return
                }
            }
        }
    }

    private func needToUpdateVersion(completion: Bool -> Void) {
        var stickersVersion = StickersVersion()
        let query = StickersVersion.sortedQuery
        let queryFromLocal = StickersVersion.sortedQuery
        queryFromLocal.fromLocalDatastore()
        
        guard ReachabilityHelper.isReachable() else {
            completion(false)
            
            return
        }
        
        query.getFirstObjectInBackgroundWithBlock { object, error in
            if let error = error {
                log.debug(error.localizedDescription)
                completion(false)
                
                return
            }
            
            guard let object = object as? StickersVersion else {
                return
            }
            
            stickersVersion = object
            queryFromLocal.getFirstObjectInBackgroundWithBlock { localObject, error in
                if let error = error {
                    log.debug(error.localizedDescription)
                    completion(true)
                    
                    return
                }
                
                guard let localObject = localObject as? StickersVersion else {
                    return
                }
                
                if stickersVersion.version > localObject.version {
                    completion(true)
                } else {
                    completion (false)
                }
            }
        }
    }

}
