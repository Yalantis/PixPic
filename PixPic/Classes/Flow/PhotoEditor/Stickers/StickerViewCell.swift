//
//  EffectViewCell.swift
//  PixPic
//
//  Created by Illya on 1/29/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class StickerViewCell: UICollectionViewCell, CellInterface {

    @IBOutlet fileprivate weak var stickerImage: UIImageView!

    func setStickerContent(_ sticker: Sticker) {
        downloadImageFromFile(sticker.image)
    }

    fileprivate func downloadImageFromFile(_ file: PFFile) {
        stickerImage.image = UIImage.stickerPlaceholderImage
        file.getImage { image, error in
            if let error = error {
                log.debug(error.localizedDescription)
            } else {
                self.stickerImage.image = image
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        stickerImage.image = nil
    }
    
}
