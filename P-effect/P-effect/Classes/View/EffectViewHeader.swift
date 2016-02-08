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
    
    private var completion: (() -> Void)!
    
    func configureWith(group group: EffectsGroup, completion: (() -> Void)) {
        downloadImageFromFile(group.image)
        label.text = group.label
        self.completion = completion
        
        let recognizer = UITapGestureRecognizer(target: self, action: "toggleGroup")
        addGestureRecognizer(recognizer)
    }
    
    private func downloadImageFromFile(file: PFFile) {
        ImageLoaderService.getImageForContentItem(file) { image, error in
            if let image = image {
                self.image.image = image
            } else {
                print("\(error)")
            }
        }
    }
    
    func toggleGroup() {
        completion()
    }
    
}
