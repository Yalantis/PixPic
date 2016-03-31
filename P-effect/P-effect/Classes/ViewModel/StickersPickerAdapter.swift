//
//  EffectsPickerModel.swift
//  P-effect
//
//  Created by Illya on 1/26/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

private let animationDuration = 0.3

class StickersPickerAdapter: NSObject {
    
    private var currentGroupNumber: Int?
    private var stickersGroups: [StickersModel]?
    private var headers = [Int: UIView]()
    private var currentHeader: UIView?
    private var currentContentOffset: CGPoint!
    
    override init() {
        super.init()
        
        _ = StickersGroup()
        _ = Sticker()
    }
    
    func stickerImage(atIndexPath indexPath: NSIndexPath, completion: (UIImage?, NSError?) -> Void) {
        guard let currentGroupNumber = currentGroupNumber, let stickersGroups = stickersGroups else {
            return
        }
        let image = stickersGroups[currentGroupNumber].stickers[indexPath.row].image
        ImageLoaderService.getImageForContentItem(image) { image, error in
            if let error = error {
                completion(nil, error)
                
                return
            }
            if let image = image {
                completion(image, nil)
            }
        }
    }
    
    func sortStickersGroups(groups: [StickersModel]) {
        stickersGroups = groups.sort {
            $0.stickersGroup.label > $1.stickersGroup.label
        }
    }
    
    // MARK: - Private methods
    private func calculateCellsIndexPath(section section: Int, count: Int = 0) -> [NSIndexPath] {
        var cells = [NSIndexPath]()
        
        guard let stickersGroups = stickersGroups else {
            return cells
        }
                
        for i in 0..<stickersGroups[section].stickers.count {
            cells.append(NSIndexPath(forRow: i, inSection: 0))
        }
        
        return cells
    }
    
    private func calculateOtherSectionsIndexPath(section section: Int) -> NSIndexSet {
        let sections = NSMutableIndexSet()
        
        guard let stickersGroups = stickersGroups else {
            return sections
        }
        
        for i in 0..<stickersGroups.count {
            if i != section {
                sections.addIndexes(NSIndexSet(index: i))
            }
        }
        
        return sections
    }

}

// MARK: - UICollectionViewDataSource
extension StickersPickerAdapter: UICollectionViewDataSource {

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        let isGroupSelected = currentGroupNumber != nil
        let stickersGroupsQuantity = stickersGroups?.count ?? 0
        return isGroupSelected ? 1 : stickersGroupsQuantity
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let currentGroupNumber = currentGroupNumber {
            return stickersGroups![currentGroupNumber].stickers.count
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
            Constants.StickerPicker.StickerPickerCellIdentifier,
            forIndexPath: indexPath
            ) as! StickerViewCell
        
        if let stickersGroups = stickersGroups {
            let sticker = stickersGroups[currentGroupNumber ?? 0].stickers[indexPath.row]
            cell.setStickerContent(sticker)
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var reusableview = UICollectionReusableView()
        
        if kind == UICollectionElementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(
                kind,
                withReuseIdentifier: StickersGroupHeaderView.identifier,
                forIndexPath: indexPath
                ) as! StickersGroupHeaderView
            
            guard let stickersGroups = stickersGroups else {
                return reusableview
            }
            let group = stickersGroups[currentGroupNumber ?? indexPath.section]
            
            headerView.configureWith(group: group.stickersGroup) {
                self.currentHeader = headerView
                collectionView.bringSubviewToFront(self.currentHeader!)
                
                if self.currentGroupNumber == nil {
                    self.currentContentOffset = collectionView.contentOffset
                    collectionView.performBatchUpdates({
                        self.currentGroupNumber = indexPath.section
                        
                        collectionView.deleteSections(self.calculateOtherSectionsIndexPath(section: indexPath.section))
                        collectionView.insertItemsAtIndexPaths(self.calculateCellsIndexPath(section: indexPath.section, count: collectionView.numberOfItemsInSection(indexPath.section)))
                        }, completion: { finished in
                            collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                    })
                    
                    return true
                } else {
                    let lastGroupNumber = self.currentGroupNumber!
                    collectionView.performBatchUpdates({
                        self.currentGroupNumber = nil
                        
                        collectionView.deleteItemsAtIndexPaths(self.calculateCellsIndexPath(section: lastGroupNumber))
                        collectionView.insertSections(self.calculateOtherSectionsIndexPath(section: lastGroupNumber))
                        }, completion: { finished in
                            collectionView.setContentOffset(self.currentContentOffset, animated: true)
                    })
                    
                    return false
                }
            }
            reusableview = headerView
        }
        
        return reusableview
    }
    
}
