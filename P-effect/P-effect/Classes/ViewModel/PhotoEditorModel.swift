//
//  PhotoEditorModel.swift
//  P-effect
//
//  Created by Illya on 1/26/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class PhotoEditorModel: NSObject {
    
    var originalImage: UIImage
    
    init(image: UIImage) {
        originalImage = image
        
        super.init()
    }
    
    func postImage(image: UIImage) {
        
    }
    
    func saveImageToLibrary(image: UIImage) {
        
    }
}
