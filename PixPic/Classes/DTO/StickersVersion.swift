//
//  EffectsVersion.swift
//  PixPic
//
//  Created by Illya on 1/28/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

class StickersVersion: PFObject {
    
    @NSManaged var version: Float
    private static var onceToken: dispatch_once_t = 0
    
    static var sortedQuery: PFQuery {
        let query = PFQuery(className: StickersVersion.parseClassName())
        query.orderByDescending("version")
        
        return query
    }

    var groupsRelation: PFRelation! {
        return relationForKey("groupsRelation")
    }
    
    override class func initialize() {
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
}

extension StickersVersion: PFSubclassing {
    
    static func parseClassName() -> String {
        return "EffectsVersion"
    }
    
}

