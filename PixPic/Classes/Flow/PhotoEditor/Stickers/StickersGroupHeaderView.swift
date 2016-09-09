//
//  EffectViewHeader.swift
//  PixPic
//
//  Created by AndrewPetrov on 2/8/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

private let tintColorAnimationDuration: NSTimeInterval = 0.2

class StickersGroupHeaderView: UICollectionReusableView, CellInterface {

    private var headerSelectionCompletion: ((() -> Void) -> Void)!
    private var isSelected = false

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var label: UILabel!

    func configureWith(group group: StickersGroup, headerSelectionCompletion: (() -> Void) -> Void) {
        downloadImageFromFile(group.image)
        label.text = group.label
        self.headerSelectionCompletion = headerSelectionCompletion

        let recognizer = UITapGestureRecognizer(target: self, action: #selector(toggleGroup))
        addGestureRecognizer(recognizer)
    }

    @objc private func toggleGroup() {
        headerSelectionCompletion { [weak self] in
            guard let this = self else {
                return
            }
            this.isSelected = !this.isSelected
            let color = this.isSelected ? UIColor.appTintColor() : UIColor.appWhiteColor()
            UIView.animateWithDuration(
                tintColorAnimationDuration,
                delay: 0,
                options: [.CurveLinear],
                animations: {
                    this.imageView.tintColor = color
                    this.label.textColor = color
                }, completion: nil
            )
        }

    }

    private func downloadImageFromFile(file: PFFile) {
        imageView.image = UIImage.stickerPlaceholderImage
        file.getImage { image, error in
            if let image = image {
                self.imageView.image = image.imageWithRenderingMode(.AlwaysTemplate)
                self.imageView.tintColor = UIColor.appWhiteColor()
            } else {
                log.debug(error?.localizedDescription)
            }
        }
    }

    override func prepareForReuse() {
        imageView.image = UIImage.stickerPlaceholderImage
        isSelected = false
        imageView.tintColor = UIColor.appWhiteColor()
        label.textColor = UIColor.appWhiteColor()
    }

}
