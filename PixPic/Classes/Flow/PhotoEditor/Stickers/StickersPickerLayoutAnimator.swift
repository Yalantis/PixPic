//
//  StickersPickerLayoutAnimator.swift
//  PixPic
//
//  Created by AndrewPetrov on 8/25/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

/*
 SectionsInOrder - All sections sorted alphabetically, goes one by one,
 stickers are in the buttom of the appropriate section

 SelectedSectionFirst - selected section is first, other sections position depends on selected one,
 selected section stickers are on the buttom one by one, prepeared for going up

 NotSelectedSectionsAbowe - All sections exept selected go up, selected section stickers at the same height
 as section header cell

 StickyHeaderWithItems - behaves as Apple's UICollectionViewStickyHeaderWithItems
 */
enum AnimationState {

    case SectionsInOrder, SelectedSectionFirst, NotSelectedSectionsAbowe, StickyHeaderWithItems

}

class StickersPickerLayoutAnimator {

    private var currentGroupIndex: Int?
    private var leftStickersCount = 0
    private var changeOrderHeadersCount = 0
    private weak var collectionView: UICollectionView!
    private var animationState = AnimationState.SectionsInOrder

    private var layout: StickersPickerCustomLayout {
        return StickersPickerCustomLayout(animationState: animationState,
                                          currentGroupIndex: currentGroupIndex,
                                          changeOrderHeadersCount: changeOrderHeadersCount,
                                          leftStickersCount: leftStickersCount)
    }

    init(collectionView: UICollectionView) {
        self.collectionView = collectionView
        collectionView.collectionViewLayout = layout
    }

    func switchLayout(forCurrentGroupIndex index: Int?) {
        //initial state
        if animationState == .SectionsInOrder && index == nil {
            currentGroupIndex = index
            collectionView.setCollectionViewLayout(layout, animated: false)
            //expanding
        } else if index != nil {
            currentGroupIndex = index
            leftStickersCount = 0
            collectionView.userInteractionEnabled = false
            animationState = .SelectedSectionFirst
            callculateChangeOrderHeadersCount()
            collectionView.setCollectionViewLayout(layout, animated: true) { [weak self] _ in
                guard let this = self else {
                    return
                }
                this.animationState = .NotSelectedSectionsAbowe
                this.collectionView.setCollectionViewLayout(this.layout, animated: true) { _ in
                    this.animationState = .StickyHeaderWithItems
                    this.collectionView.setCollectionViewLayout(this.layout, animated: false) { _ in
                        this.collectionView.userInteractionEnabled = true
                    }
                }
            }
            //collapsing
        } else {
            collectionView.userInteractionEnabled = false
            leftStickersCount = Int(collectionView.contentOffset.x / Constants.StickerCell.size.width)
            animationState = .NotSelectedSectionsAbowe
            collectionView.setCollectionViewLayout(layout, animated: true) { [weak self] _ in
                guard let this = self else {
                    return
                }
                this.animationState = .SelectedSectionFirst
                this.collectionView.setCollectionViewLayout(this.layout, animated: true) { _ in
                    this.animationState = .SectionsInOrder
                    this.collectionView.setCollectionViewLayout(this.layout, animated: true) { _ in
                        this.collectionView.userInteractionEnabled = true
                        this.currentGroupIndex = index
                    }
                }
            }
        }
    }

    private func callculateChangeOrderHeadersCount() {
        guard let currentGroupIndex = currentGroupIndex else {
            return
        }
        let afterCurrentHeadersCount = collectionView.numberOfSections() - currentGroupIndex - 1
        let headersOnScreenCount = Int(collectionView.frame.width / Constants.StickerCell.size.width)
        changeOrderHeadersCount = max(headersOnScreenCount - afterCurrentHeadersCount, 0)
    }
    
}
