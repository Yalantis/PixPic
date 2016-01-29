//
//  EffectsModel.swift
//  P-effect
//
//  Created by Illya on 1/28/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class EffectsModel: NSObject {
    
    var effectsGroup: EffectsGroup
    var effectsStickers: [EffectsSticker]
    
    override init() {
//        effectsVersion = EffectsVersion()
        effectsStickers = [EffectsSticker]()
        effectsGroup = EffectsGroup()
        
//
//        let image = UIImage(named: "delete_50_1")
//        let pictureData = UIImageJPEGRepresentation(image!, 0.5)
//        effectsGroup.image = PFFile(name: "image", data: pictureData!)!
//        effectsSticker.image = PFFile(name: "image", data: pictureData!)!
//        for _ in 0..<3 {
//            for _ in 0..<4 {
//                effectsGroup.stickersRelation?.addObject(effectsSticker)
//            }
//            effectsVersion.groupsRelation?.addObject(effectsGroup)
//        }
//        
        super.init()

 
    }
}
