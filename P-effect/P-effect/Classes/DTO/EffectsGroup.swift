//
//  EffectsGroup.swift
//  P-effect
//
//  Created by Illya on 1/28/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class EffectsGroup: PFObject {
    
    @NSManaged var image: PFFile
    var stickersRelation: PFRelation! {
        return relationForKey("stickersRelation")
    }
//    @NSManaged var version: EffectsVersion?
    
    override class func initialize() {
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    override class func query() -> PFQuery? {
        let query = PFQuery(className: Post.parseClassName())
//        query.includeKey("EffectsVersion")
        query.orderByDescending("updatedAt")
        return query
    }
    
}

extension EffectsGroup: PFSubclassing {
    
    class func parseClassName() -> String {
        return "EffectsGroup"
    }
    
}
