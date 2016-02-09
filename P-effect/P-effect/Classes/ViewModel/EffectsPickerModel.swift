//
//  EffectsPickerModel.swift
//  P-effect
//
//  Created by Illya on 1/26/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

let animationDuration: Double = 0.5

class EffectsPickerModel: NSObject {
    
    private var currentGroupNumber: Int?
    private var effectsGroups: [EffectsModel]?
    private var headers = [Int:UIView]()
    
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
        guard let currentGroupNumber = currentGroupNumber else {
            return
        }
        let image = effectsGroups![currentGroupNumber].effectsStickers[indexPath.row].image
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
        if currentGroupNumber != nil {
            return 1
        } else {
            return effectsGroups?.count ?? 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let currentGroupNumber = currentGroupNumber {
            return effectsGroups![currentGroupNumber].effectsStickers.count
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
            Constants.EffectsPicker.EffectsPickerCellIdentifier,
            forIndexPath: indexPath
            ) as! EffectViewCell
        cell.setStickerContent(effectsGroups![currentGroupNumber!].effectsStickers[indexPath.row])
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var reusableview = UICollectionReusableView()
        
        if kind == UICollectionElementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: EffectViewHeader.identifier, forIndexPath: indexPath) as! EffectViewHeader
            guard let effectsGroups = effectsGroups else {
                return reusableview
            }
            let group = effectsGroups[currentGroupNumber ?? indexPath.section]
            headerView.configureWith(group: group.effectsGroup) {
                
                if self.currentGroupNumber == nil {
                    UIView.animateWithDuration(
                        animationDuration,
                        delay: 0,
                        options: .CurveEaseInOut,
                        animations: {
                            for (_, header) in self.headers where header != headerView {
                                var newFrame = header.frame
                                newFrame.origin.y = headerView.frame.size.width
                                header.frame = newFrame
                            }
                        },
                        completion: { _ in
                            UIView.animateWithDuration(0.3,
                                delay: 0,
                                options: .CurveEaseInOut,
                                animations: { Void in
                                    var newFrame =   headerView.frame
                                    newFrame.origin = CGPoint(x: 0, y: 0)
                                    headerView.frame = newFrame
                                },
                                completion: { _ in
                                    self.currentGroupNumber = indexPath.section
                                    collectionView.reloadData()
                                    collectionView.layoutIfNeeded()
                                    
                                    for cell in collectionView.visibleCells() {
                                        var newFrame = cell.frame
                                        newFrame.origin.y = cell.frame.size.height
                                        cell.frame = newFrame
                                    }
                                    UIView.animateWithDuration(0.3,
                                        delay: 0,
                                        options: .CurveEaseInOut,
                                        animations: { Void in
                                            for cell in collectionView.visibleCells() {
                                                var newFrame = cell.frame
                                                newFrame.origin.y = 0
                                                cell.frame = newFrame
                                            }
                                        },
                                        completion: nil)
                            })                            
                    })
                } else {
                    let lastGroupNumber = self.currentGroupNumber!
                    UIView.animateWithDuration(
                        animationDuration,
                        delay: 0,
                        options: .CurveEaseInOut,
                        animations: {
                            for cell in collectionView.visibleCells() {
                                var newFrame = cell.frame
                                newFrame.origin.y = cell.frame.size.height
                                cell.frame = newFrame
                            }
                        },
                        completion: { _ in
                            self.currentGroupNumber = nil
                            collectionView.reloadData()
                            collectionView.layoutIfNeeded()
                            let currentHeader = self.headers[lastGroupNumber]!
                            
                            var newFrame = currentHeader.frame
                            newFrame.origin.x = 0
                            currentHeader.frame = newFrame
                            
                            for (_, header) in self.headers where header != currentHeader {
                                var newFrame = header.frame
                                newFrame.origin.y = newFrame.size.height
                                header.frame = newFrame
                            }
                            UIView.animateWithDuration(animationDuration,
                                delay: 0,
                                options: .CurveEaseInOut,
                                animations: { Void in
                                    var newFrame =   currentHeader.frame
                                    newFrame.origin.x = currentHeader.frame.size.width * CGFloat(lastGroupNumber)
                                    currentHeader.frame = newFrame
                                }, completion: { _ in
                                    UIView.animateWithDuration(animationDuration,
                                        delay: 0,
                                        options: .CurveEaseInOut,
                                        animations: { Void in
                                            for (_, header) in self.headers where header != currentHeader {
                                                var newFrame = header.frame
                                                newFrame.origin.y = 0
                                                header.frame = newFrame
                                            }
                                        }, completion: nil)
                            })
                    })
                }
            }
            reusableview = headerView
            headers[indexPath.section] = headerView
        }
        return reusableview
    }
    
}

