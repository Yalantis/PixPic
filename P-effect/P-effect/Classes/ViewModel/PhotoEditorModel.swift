//
//  PhotoEditorModel.swift
//  P-effect
//
//  Created by Illya on 1/26/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class PhotoEditorModel: NSObject {
    
    private let setedOriginalImage: UIImage
    
    init(image: UIImage) {
        setedOriginalImage = image
        
        super.init()
    }
    
    func postImage(image: UIImage) {
        
    }
    
    func saveImageToLibrary(image: UIImage) {
        
    }
    
    func originalImage() -> UIImage {
        return setedOriginalImage
    }
}
