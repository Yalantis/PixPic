//
//  EffectsPickerModel.swift
//  PixPic
//
//  Created by Illya on 1/26/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

private let animationDuration = 0.3
private let defaultNumberOfStickerGroups = 6
private let defaultNumberOfStickersInGroup = 6

class StickersPickerAdapter: NSObject {
    
    private var currentGroupIndex: Int?
    private var stickersModels: [StickersModel]?
    private var headers = [Int: UIView]()
    private var currentHeader: UIView?
    private var currentContentOffset: CGPoint!
    
    func stickerImage(atIndexPath indexPath: NSIndexPath, completion: (UIImage?, NSError?) -> Void) {
        guard let currentGroupNumber = currentGroupIndex, let stickersGroups = stickersModels else {
            return
        }
        let image = stickersGroups[currentGroupNumber].stickers[indexPath.row].image
        image.getImage { image, error in
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
        stickersModels = groups.sort {
            $0.stickersGroup.label < $1.stickersGroup.label
        }
    }
    
    // MARK: - Private methods
    private func calculateCellsIndexPath(section section: Int, count: Int = 0) -> [NSIndexPath] {
        var cells = [NSIndexPath]()
        
        guard let stickersGroups = stickersModels else {
            return cells
        }
                
        for i in 0..<stickersGroups[section].stickers.count {
            cells.append(NSIndexPath(forRow: i, inSection: 0))
        }
        
        return cells
    }
    
    private func calculateOtherSectionsIndexPath(section section: Int) -> NSIndexSet {
        let sections = NSMutableIndexSet()
        
        guard let stickersGroups = stickersModels else {
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
        let numberOfSections: Int
        let isGroupSelected = currentGroupIndex != nil
        if isGroupSelected {
            numberOfSections = 1
        } else {
            numberOfSections = stickersModels?.count ?? defaultNumberOfStickerGroups
        }
        
        return numberOfSections
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let currentGroupNumber = currentGroupIndex {
            return stickersModels?[currentGroupNumber].stickers.count ?? defaultNumberOfStickersInGroup
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
            StickerViewCell.id,
            forIndexPath: indexPath
            ) as! StickerViewCell
        
        if let stickersGroups = stickersModels {
            let sticker = stickersGroups[currentGroupIndex ?? 0].stickers[indexPath.row]
            cell.setStickerContent(sticker)
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        var reusableview = UICollectionReusableView()
        
        if kind == UICollectionElementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(
                kind,
                withReuseIdentifier: StickersGroupHeaderView.id,
                forIndexPath: indexPath
                ) as! StickersGroupHeaderView
            
            guard let stickersGroups = stickersModels else {
                return headerView
            }
            let group = stickersGroups[currentGroupIndex ?? indexPath.section]
            
            headerView.configureWith(group: group.stickersGroup) {
                self.currentHeader = headerView
                collectionView.bringSubviewToFront(self.currentHeader!)
                
                if self.currentGroupIndex == nil {
                    self.currentContentOffset = collectionView.contentOffset
                    collectionView.performBatchUpdates({
                        self.currentGroupIndex = indexPath.section
                        
                        collectionView.deleteSections(self.calculateOtherSectionsIndexPath(section: indexPath.section))
                        collectionView.insertItemsAtIndexPaths(self.calculateCellsIndexPath(section: indexPath.section, count: collectionView.numberOfItemsInSection(indexPath.section)))
                        }, completion: { finished in
                            collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
                    })
                    
                    return true
                } else {
                    let lastGroupNumber = self.currentGroupIndex!
                    collectionView.performBatchUpdates({
                        self.currentGroupIndex = nil
                        
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
