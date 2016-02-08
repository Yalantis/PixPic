//
//  EffectsPickerModel.swift
//  P-effect
//
//  Created by Illya on 1/26/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class EffectsPickerModel: NSObject {
    
    private var effectsGroups: [EffectsModel]?
    var shownGroupNumber: Int?
    
    override init() {
        super.init()
        
        EffectsGroup()
        EffectsSticker()
    }
    
    func downloadEffects(completion: (Bool) -> ()) {
        LoaderService.loadEffects { [weak self] objects, error in
            if let objects = objects {
                self?.effectsGroups = objects
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func effectImageAtIndexPath(indexPath: NSIndexPath, completion: (UIImage?, NSError?) -> ()) {
        let image = effectsGroups![shownGroupNumber!].effectsStickers[indexPath.row].image
        ImageLoaderService.getImageForContentItem(image) {
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
        if let _ = shownGroupNumber {
            return 1
        } else {
            return effectsGroups?.count ?? 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let shownGroupNumber = shownGroupNumber {
            return effectsGroups![shownGroupNumber].effectsStickers.count
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
            Constants.EffectsPicker.EffectsPickerCellIdentifier,
            forIndexPath: indexPath
            ) as! EffectViewCell
        guard let effectsGroups = effectsGroups else {
            return cell
        }
        cell.setStickerContent(effectsGroups[shownGroupNumber!].effectsStickers[indexPath.row])
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var reusableview: UICollectionReusableView = UICollectionReusableView()
        
        if kind == UICollectionElementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: EffectViewHeader.identifier, forIndexPath: indexPath) as! EffectViewHeader
            
            guard let effectsGroups = effectsGroups else {
                return reusableview
            }
            let group = effectsGroups[shownGroupNumber ?? indexPath.section]
            headerView.setGroupContent(group.effectsGroup) {
                if self.shownGroupNumber == nil {
                    self.shownGroupNumber = indexPath.section
                } else {
                    self.shownGroupNumber = nil
                }
                collectionView.reloadData()
            }
            reusableview = headerView
        }
        return reusableview
    }
    
}