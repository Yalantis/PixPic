//
//  EffectsPickerModel.swift
//  PixPic
//
//  Created by Illya on 1/26/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

private let changingLayoutDuration = 0.3
private let defaultNumberOfStickerGroups = 5
private let defaultNumberOfStickersInGroup = 5

class StickersPickerAdapter: NSObject {

    private var isUserInteractionsEnabled = true
    private var currentGroupIndex: Int? {
        didSet {
            currentHeaderIndexChangingHandler(currentGroupIndex)
        }
    }
    var currentHeaderIndexChangingHandler: (Int? -> ())!
    private var stickersModels: [StickersModel]?

    func stickerImage(atIndexPath indexPath: NSIndexPath, completion: (UIImage?, NSError?) -> Void) {
        guard let currentGroupNumber = currentGroupIndex, stickersGroups = stickersModels else {
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

}

// MARK: - UICollectionViewDataSource
extension StickersPickerAdapter: UICollectionViewDataSource {

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return  stickersModels?.count ?? defaultNumberOfStickerGroups
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickersModels?[section].stickers.count ?? defaultNumberOfStickersInGroup
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
            StickerViewCell.id,
            forIndexPath: indexPath
            ) as? StickerViewCell {

            if let stickersGroups = stickersModels {
                let sticker = stickersGroups[indexPath.section].stickers[indexPath.row]
                cell.setStickerContent(sticker)
            }

            return cell
        }
        
        return UICollectionViewCell()
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
            let group = stickersGroups[indexPath.section].stickersGroup

            headerView.configureWith(group: group) { [weak self] complition in
                guard let this = self where this.isUserInteractionsEnabled == true else {
                    return
                }
                this.isUserInteractionsEnabled = false
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(changingLayoutDuration * Double(NSEC_PER_SEC)))
                dispatch_after(delayTime, dispatch_get_main_queue()) {
                    this.isUserInteractionsEnabled = true
                }
                if this.currentGroupIndex == nil {
                    this.currentGroupIndex = indexPath.section
                } else {
                    this.currentGroupIndex = nil
                }
                complition()
            }

            reusableview = headerView
        }

        return reusableview
    }

}
