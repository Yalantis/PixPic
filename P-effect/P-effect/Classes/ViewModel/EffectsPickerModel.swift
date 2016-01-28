//
//  EffectsPickerModel.swift
//  P-effect
//
//  Created by Illya on 1/26/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class EffectsPickerModel: NSObject {
    var effects: Int
    
    
    override init() {
        effects = 3

        super.init()
    }

}

extension EffectsPickerModel: UICollectionViewDataSource {
    
     func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
     func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return effects
    }
    
     func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
            Constants.EffectsPicker.EffectsPickerCellIdentifier, forIndexPath: indexPath
        )
        
        return cell
    }
}