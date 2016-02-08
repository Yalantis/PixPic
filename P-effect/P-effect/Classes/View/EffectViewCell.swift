//
//  EffectViewCell.swift
//  P-effect
//
//  Created by Illya on 1/29/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class EffectViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var effectImage: UIImageView!
    
    func setStickerContent(sticker: EffectsSticker) {
        downloadImageFromFile(sticker.image)
    }
    
    private func downloadImageFromFile(file: PFFile) {
        ImageLoaderService.getImageForContentItem(file) { [weak self] image, error in
            if let error = error {
                print("\(error)")
            } else {
                self?.effectImage.image = image
            }
        }
    }
}
