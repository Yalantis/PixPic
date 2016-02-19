//
//  EffectsSticker.swift
//  P-effect
//
//  Created by Illya on 1/28/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

class EffectsSticker: PFObject {
    
    @NSManaged var image: PFFile
    private static var onceToken: dispatch_once_t = 0

    override class func initialize() {
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }

}

extension EffectsSticker: PFSubclassing {
        
    class func parseClassName() -> String {
        return "EffectsSticker"
    }
        
}