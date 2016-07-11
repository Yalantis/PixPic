//
//  EffectsService.swift
//  PixPic
//
//  Created by anna on 2/16/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

typealias LoadingStickersCompletion = (objects: [StickersModel]?, error: NSError?) -> Void

class StickersLoaderService {
    
    private var isQueryFromLocalDataStore = false
    
    func loadStickers(completion: LoadingStickersCompletion) {
        
        checkIfNeedToUpdateVersion { [weak self] needUpdate in
            guard let this = self else {
                return
            }
            let query = StickersVersion.sortedQuery
            if !needUpdate {
                query.fromLocalDatastore()
                this.isQueryFromLocalDataStore = true
            }
            query.getFirstObjectInBackgroundWithBlock { object, error in
                if let error = error {
                    log.debug(error.localizedDescription)
                    completion(objects: nil, error: error)
                    
                    return
                }
                
                guard let stickersVersion = object as? StickersVersion  else {
                    completion(objects: nil, error: nil)
                    
                    return
                }
                
                this.loadStickersGroups(stickersVersion) { objects, error in
                    stickersVersion.pinInBackground()
                    completion(objects: objects, error: error)
                }
            }
        }
    }
    
    private func loadStickersGroups(stickersVersion: StickersVersion, completion: LoadingStickersCompletion) {
        let groupsRelationQuery = stickersVersion.groupsRelation.query()
        
        if isQueryFromLocalDataStore {
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
        
        let dispatchGroup = dispatch_group_create()
        
        for group in stickersGroups {
            dispatch_group_enter(dispatchGroup)
            
            group.image.getDataInBackgroundWithBlock { _, _ in
                group.pinInBackgroundWithBlock { _, _ in
                    let stickersRelationQuery = group.stickersRelation.query().addAscendingOrder("createdAt")
                    
                    if self.isQueryFromLocalDataStore {
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
                        
                        dispatch_group_leave(dispatchGroup)
                        
                        for sticker in stickers {
                            sticker.image.getDataInBackgroundWithBlock { _, _ in
                                sticker.pinInBackground()
                            }
                        }
                    }
                }
            }
        }
        
        dispatch_group_notify(dispatchGroup, dispatch_get_main_queue()) {
            completion(objects: stickersModels, error: nil)
        }
        
    }
    
    private func checkIfNeedToUpdateVersion(completion: Bool -> Void) {
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
            
            guard let remoteVersion = object as? StickersVersion else {
                return
            }
            
            queryFromLocal.getFirstObjectInBackgroundWithBlock { localObject, error in
                if let error = error {
                    log.debug(error.localizedDescription)
                    completion(true)
                    
                    return
                }
                
                guard let localObject = localObject as? StickersVersion else {
                    return
                }
                
                if remoteVersion.version > localObject.version {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
}
