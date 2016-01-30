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
        effectsStickers = [EffectsSticker]()
        effectsGroup = EffectsGroup()

        super.init()
     }
}
