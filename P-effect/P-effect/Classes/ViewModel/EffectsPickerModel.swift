//
//  EffectsPickerModel.swift
//  P-effect
//
//  Created by Illya on 1/26/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class EffectsPickerModel: NSObject {
    
    private var effects: [EffectsModel]?
    var groupsShown: Bool?
    var shownGroupNumber: Int?
    
    override init() {
        
        super.init()
        
        registerParseSubclasses()
    }
    
    func downloadEffects(completion: (Bool) -> ()) {
        LoaderService.loadEffects { [weak self] objects, error in
            if let objects = objects {
                self?.effects = objects
                print(objects)
                completion(true)
            }
        }
    }
    
    private func registerParseSubclasses() {
        EffectsGroup()
        EffectsSticker()
    }
    
    func effectImageAtIndexPath(indexPath: NSIndexPath, completion: (UIImage?, NSError?) -> ()) {
        let imageLoader = ImageLoaderService()
        let image = effects![shownGroupNumber!].effectsStickers[indexPath.row - 1].image
        imageLoader.getImageForContentItem(image) {
            image, error in
            if let error = error {
                completion(nil, error)
                return
            }
            if let image = image {
                completion(image, nil)
            }
        }
    }
}



extension EffectsPickerModel: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let effects = effects
            else { return 0 }
        if groupsShown == true {
            return effects.count
        } else {
            guard let shownGroupNumber = shownGroupNumber
                else { return 0 }
            return  effects[shownGroupNumber].effectsStickers.count + 1
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
            Constants.EffectsPicker.EffectsPickerCellIdentifier, forIndexPath: indexPath
            ) as! EffectViewCell
        guard let groupsShown = groupsShown, let effects = effects
            else {return cell}
        if groupsShown == true {
            cell.setGroupContent(effects[indexPath.row].effectsGroup)
        } else {
            if let shownGroupNumber = shownGroupNumber {
                if indexPath.row == 0 {
                    cell.setGroupContent(effects[shownGroupNumber].effectsGroup)
                } else {
                    cell.setStickerContent(effects[shownGroupNumber].effectsStickers[indexPath.row - 1])
                }
            }
        }
        return cell
    }
}