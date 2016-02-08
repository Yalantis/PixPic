//
//  EffectViewHeader.swift
//  P-effect
//
//  Created by AndrewPetrov on 2/8/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class EffectViewHeader: UICollectionReusableView {
    
    static let identifier = "EffectViewHeaderIdentifier"
    
    @IBOutlet private weak var image: UIImageView!
    @IBOutlet private weak var label: UILabel!
    
    private var complition: (() -> Void)?
    
    func setGroupContent(group: EffectsGroup, complition: (() -> Void)) {
        downloadImageFromFile(group.image)
        label.text = group.label
        self.complition = complition
        
        let singleFingerTap = UITapGestureRecognizer(target: self, action: "toggleGroup")
        addGestureRecognizer(singleFingerTap)
    }
    
    private func downloadImageFromFile(file: PFFile) {
        ImageLoaderService.getImageForContentItem(file) { [weak self] image, error in
            if let error = error {
                print("\(error)")
            } else {
                self?.image.image = image
            }
        }
    }
    
    func toggleGroup() {
        complition?()
    }
    
}
