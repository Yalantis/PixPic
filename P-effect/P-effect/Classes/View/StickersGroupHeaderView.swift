//
//  EffectViewHeader.swift
//  P-effect
//
//  Created by AndrewPetrov on 2/8/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class StickersGroupHeaderView: UICollectionReusableView, CellInterface {
    
    static let identifier = "StickersGroupHeaderViewIdentifier"
    
    private var completion: (() -> Bool)!
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var label: UILabel!
    
    func configureWith(group group: StickersGroup, completion: (() -> Bool)) {
        downloadImageFromFile(group.image)
        label.text = group.label
        self.completion = completion
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(toggleGroup))
        addGestureRecognizer(recognizer)
    }
        
    dynamic private func toggleGroup() {
        let isSelected = completion()
        let color = isSelected ? UIColor.appBlueColor : UIColor.appWhiteColor
        UIView.animateWithDuration(
            0.2,
            delay: 0,
            options: [.CurveLinear, .BeginFromCurrentState],
            animations: {
                self.imageView.tintColor = color
            },
            completion: nil
        )
    }
    
    private func downloadImageFromFile(file: PFFile) {
        ImageLoaderService.getImageForContentItem(file) { image, error in
            if let image = image {
                self.imageView.image = image.imageWithRenderingMode(.AlwaysTemplate)
                self.imageView.tintColor = UIColor.appWhiteColor
            } else {
                log.debug(error?.localizedDescription)
            }
        }
    }
    
}
