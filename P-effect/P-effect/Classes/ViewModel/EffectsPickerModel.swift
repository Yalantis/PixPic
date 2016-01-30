//
//  EffectsPickerModel.swift
//  P-effect
//
//  Created by Illya on 1/26/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class EffectsPickerModel: NSObject {
    
    var effects: [EffectsModel]?
    var groupsShown: Bool?
    var shownGroupNumber: Int?
    
    override init() {
        
        super.init()
        
        registerParseSubclasses()
    }
    
    func downloadEffects(completion: (Bool) -> ()) {
        LoaderService.loadEffects { [weak self] (objects, error) in
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
    
    func effectImageAtIndexPath(indexPath: NSIndexPath, completion: (UIImage) -> ()) {
        let imageLoader = ImageLoaderService()
        imageLoader.getImageForContentItem(effects![shownGroupNumber!].effectsStickers[indexPath.row - 1].image) { (image, error) -> () in
            if error != nil {
                return
            } else {
                if let image = image {
                    completion(image)
                }
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
            else { return 0}
            if groupsShown == true{
                return effects.count
            } else {
                if let shownGroupNumber = shownGroupNumber {
                    return  effects[shownGroupNumber].effectsStickers.count + 1
                }
            }
        return 0
    }
    //        return (effects?.count)!


    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
            Constants.EffectsPicker.EffectsPickerCellIdentifier, forIndexPath: indexPath
            ) as! EffectViewCell
        if let groupsShown = groupsShown, let effects = effects {
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
        }
        return cell
    }
}