//
//  EffectsGroup.swift
//  PixPic
//
//  Created by Illya on 1/28/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

class StickersGroup: PFObject {
    
    @NSManaged var image: PFFile
    @NSManaged var label: String
    private static var onceToken: dispatch_once_t = 0
    
    var stickersRelation: PFRelation! {
        return relationForKey("stickersRelation")
    }
    
    override class func initialize() {
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
}

extension StickersGroup: PFSubclassing {
    
    static func parseClassName() -> String {
        return "EffectsGroup"
    }
    
}
