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

    fileprivate var isUserInteractionsEnabled = true
    fileprivate var currentGroupIndex: Int? {
        didSet {
            currentHeaderIndexChangingHandler(currentGroupIndex)
        }
    }
    var currentHeaderIndexChangingHandler: ((Int?) -> ())!
    fileprivate var stickersModels: [StickersModel]?

    func stickerImage(atIndexPath indexPath: IndexPath, completion: @escaping (UIImage?, NSError?) -> Void) {
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

    func sortStickersGroups(_ groups: [StickersModel]) {
        stickersModels = groups.sorted {
            $0.stickersGroup.label < $1.stickersGroup.label
        }
    }

}

// MARK: - UICollectionViewDataSource
extension StickersPickerAdapter: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return  stickersModels?.count ?? defaultNumberOfStickerGroups
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stickersModels?[section].stickers.count ?? defaultNumberOfStickersInGroup
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: StickerViewCell.id,
            for: indexPath
            ) as? StickerViewCell {

            if let stickersGroups = stickersModels {
                let sticker = stickersGroups[indexPath.section].stickers[indexPath.row]
                cell.setStickerContent(sticker)
            }

            return cell
        }
        
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableview = UICollectionReusableView()

        if kind == UICollectionElementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: StickersGroupHeaderView.id,
                for: indexPath
                ) as! StickersGroupHeaderView

            guard let stickersGroups = stickersModels else {
                return headerView
            }
            let group = stickersGroups[indexPath.section].stickersGroup

            headerView.configureWith(group: group) { [weak self] complition in
                guard let this = self, this.isUserInteractionsEnabled == true else {
                    return
                }
                this.isUserInteractionsEnabled = false
                let delayTime = DispatchTime.now() + Double(Int64(changingLayoutDuration * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime) {
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
