//
//  EffectViewCell.swift
//  P-effect
//
//  Created by Illya on 1/29/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class StickerViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var stickerImage: UIImageView!
    
    func setStickerContent(sticker: Sticker) {
        downloadImageFromFile(sticker.image)
    }
    
    private func downloadImageFromFile(file: PFFile) {
        ImageLoaderHelper.getImageForContentItem(file) { image, error in
            if let error = error {
                log.debug(error.localizedDescription)
            } else {
                self.stickerImage.image = image
            }
        }
    }
}
