//
//  EffectsPickerModel.swift
//  P-effect
//
//  Created by Illya on 1/26/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

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
                        0.7,
                        delay: 0,
                        usingSpringWithDamping: 0.7,
                        initialSpringVelocity: 0.7,
                        options: .CurveEaseInOut,
                        animations: {
                            
                            //                            print("headers === \(self.headers)")
                            for (_, header) in self.headers where header != headerView {
                                var newFrame = header.frame
                                newFrame.origin.y = headerView.frame.size.width
                                header.frame = newFrame
                                
                                //                                header.alpha = 0
                            }
                            
                            
                            var newFrame =   headerView.frame
                            newFrame.origin = CGPoint(x: 0, y: 0)
                            headerView.frame = newFrame
                            
                            
                            
                        },
                        completion: { answer in
                            
                            self.currentGroupNumber = indexPath.section
                            collectionView.reloadData()
                            
                            
                            
                            let numberOfCells = self.collectionView(collectionView, numberOfItemsInSection: 0)
                            //                            UICollectionViewLayout *layout = self.collectionView.collectionViewLayout;
                            //                            for (var i = 0; i < numberOfCells; i++) {
                            //                                let numberOfCells = self.collectionView(collectionView, numberOfItemsInSection: 0)
                            //                                
                            //                                UICollectionViewLayoutAttributes *layoutAttributes = [layout layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
                            //                                CGRect cellFrame = layoutAttributes.frame;
                            //                                NSLog(@"%i - %@", i, NSStringFromCGRect(cellFrame));
                            //                            }
                            //                            
                            //                            
                            
                            for cell in collectionView.visibleCells() {
                                
                                var newFrame = cell.frame
                                newFrame.origin.y = cell.frame.size.width
                                cell.frame = newFrame
                                
                            }
                            print("\(collectionView.visibleCells())")
                            
                            
                            UIView.animateWithDuration(0.7,
                                delay: 0.7,
                                options: .CurveEaseInOut,
                                animations: { () -> Void in
                                    
                                    collectionView.layoutIfNeeded()
                                    
                                    
                                    print("\(collectionView.visibleCells())")
                                    for cell in collectionView.visibleCells() {
                                        
                                        var newFrame = cell.frame
                                        newFrame.origin.y = 0
                                        cell.frame = newFrame
                                        
                                    }
                                    
                                    
                                    
                                    
                                }, completion: nil)
                            
                            
                            
                    })
                    
                    
                    
                    
                    
                } else {
                    UIView.animateWithDuration(
                        0.7,
                        delay: 0,
                        usingSpringWithDamping: 0.7,
                        initialSpringVelocity: 0.7,
                        options: .CurveEaseInOut,
                        animations: {
                            self.currentGroupNumber = nil
                            collectionView.reloadData()
                            
                            collectionView.layoutIfNeeded()
                            //                            var newFrame =   headerView.frame
                            //                            newFrame.origin = CGPoint(x:  headerView.frame.size.width * CGFloat(self.currentGroupNumber!), y: 0)
                            
                            //                            print("newFrame.origin === \(newFrame.origin)")
                            //                            headerView.frame = newFrame
                        },
                        completion: { answer in
                            print("\(collectionView.visibleCells())")
                            //                            collectionView.reloadData()
                            
                    })
                    
                }
                //                let newSectionIndexPath = NSIndexPath(forItem: 0, inSection: self.currentGroupNumber!)
                
                //                collectionView.scrollToItemAtIndexPath(newSectionIndexPath, atScrollPosition: .Right, animated: true)
                //                //                collectionView.scroo
                //                print("headerView1111 === \(headerView)")
                //                
                //                
                //                
                //                
                //                print("headerView2222 === \(headerView)")
            }
            reusableview = headerView
            headers[indexPath.section] = headerView
            
        }
        return reusableview
    }
    
    
}


