//
//  EffectsLayout.swift
//  PixPic
//
//  Created by AndrewPetrov on 2/10/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

private let cellSize = CGSize(width: 105, height: 105)

class StickersLayout: UICollectionViewFlowLayout {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
        super.init()

        itemSize = cellSize
        headerReferenceSize = cellSize
        scrollDirection = UICollectionViewScrollDirection.Horizontal
        sectionHeadersPinToVisibleBounds = true

        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
    }

    override func initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath)!
        var newFrame = CGRect(origin: attributes.frame.origin, size: attributes.frame.size)
        newFrame.origin.y = cellSize.height
        attributes.frame = newFrame
        attributes.alpha = 0

        return attributes
    }

    override func finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath)!
        attributes.alpha = 0

        return attributes
    }

}
