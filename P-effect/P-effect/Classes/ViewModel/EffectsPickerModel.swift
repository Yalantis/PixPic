//
//  EffectsPickerModel.swift
//  P-effect
//
//  Created by Illya on 1/26/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

let animationDuration: Double = 0.3

class EffectsPickerModel: NSObject {
    
    private var currentGroupNumber: Int?
    private var effectsGroups: [EffectsModel]?
    private var headers = [Int: UIView]()
    private var currentHeader: UIView?
    
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
                self.currentHeader = headerView
                if self.currentGroupNumber == nil {
                    UIView.animateWithDuration(
                        animationDuration,
                        delay: 0,
                        options: .CurveEaseInOut,
                        animations: {
                            self.moveViewsTo(Array(self.headers.values))
                        },
                        completion: { _ in
                            UIView.animateWithDuration(0.3,
                                delay: 0,
                                options: .CurveEaseInOut,
                                animations: { Void in
                                    headerView.moveTo(x: 0, y: 0)
                                },
                                completion: { _ in
                                    self.currentGroupNumber = indexPath.section
                                    collectionView.reloadData()
                                    collectionView.layoutIfNeeded()
                                    
                                    self.moveViewsTo(collectionView.visibleCells())
                                    UIView.animateWithDuration(0.3,
                                        delay: 0,
                                        options: .CurveEaseInOut,
                                        animations: { Void in
                                            self.moveViewsTo(collectionView.visibleCells(), y: 0)
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
                            self.moveViewsTo(collectionView.visibleCells())
                        },
                        completion: { _ in
                            self.currentGroupNumber = nil
                            collectionView.reloadData()
                            collectionView.layoutIfNeeded()
                            self.currentHeader = self.headers[lastGroupNumber]!
                            self.currentHeader!.moveTo(x: 0)
                            self.moveViewsTo(Array(self.headers.values))
                            
                            UIView.animateWithDuration(animationDuration,
                                delay: 0,
                                options: .CurveEaseInOut,
                                animations: { Void in
                                    self.currentHeader!.moveTo(x: self.currentHeader!.frame.size.width * CGFloat(lastGroupNumber))
                                }, completion: { _ in
                                    UIView.animateWithDuration(animationDuration,
                                        delay: 0,
                                        options: .CurveEaseInOut,
                                        animations: { Void in
                                            self.moveViewsTo(Array(self.headers.values), y: 0)
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
    
    private func moveViewsTo(views: [UIView], y: CGFloat? = nil) {
        for view in views where view != currentHeader {
            var newFrame = view.frame
            newFrame.origin.y = y ?? newFrame.size.height
            view.frame = newFrame
        }
    }
    
}

extension UIView {
    
    func  moveTo(x x: CGFloat? = nil, y: CGFloat? = nil) {
        var newFrame = frame
        if let x = x {
            newFrame.origin.x = x
        }
        if let y = y {
            newFrame.origin.y = y
        }
        frame = newFrame
    }
    
}



