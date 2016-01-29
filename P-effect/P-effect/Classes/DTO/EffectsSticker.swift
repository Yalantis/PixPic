//
//  EffectsSticker.swift
//  P-effect
//
//  Created by Illya on 1/28/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

class EffectsSticker: PFObject {
    
    @NSManaged var image: PFFile
//    @NSManaged var group: EffectsGroup?
    
    override class func initialize() {
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    override class func query() -> PFQuery? {
        let query = PFQuery(className: EffectsSticker.parseClassName())
        return query
    }
        
}

extension EffectsSticker: PFSubclassing {
        
    class func parseClassName() -> String {
        return "EffectsSticker"
    }
        
}