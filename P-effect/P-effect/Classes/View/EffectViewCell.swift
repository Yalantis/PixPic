//
//  EffectViewCell.swift
//  P-effect
//
//  Created by Illya on 1/29/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class EffectViewCell: UICollectionViewCell {
    
    @IBOutlet weak var effectImage: UIImageView!
    
    private let imageLoader = ImageLoaderService()
    
    func setGroupContent(group: EffectsGroup) {
        imageLoader.getImageForContentItem(group.image) { [weak self] image, error in
            if let error = error {
                print("\(error)")
            } else {
                self?.effectImage.image = image
            }
        }
    }
    
    func setStickerContent(sticker: EffectsSticker) {
        imageLoader.getImageForContentItem(sticker.image) { [weak self] image, error in
            if let error = error {
                print("\(error)")
            } else {
                self?.effectImage.image = image
            }
        }
    }
    
}
