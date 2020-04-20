//
//  PhotoEditorModel.swift
//  PixPic
//
//  Created by Illya on 1/26/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class PhotoEditorModel: NSObject {

    fileprivate(set) var originalImage: UIImage

    init(image: UIImage) {
        originalImage = image

        super.init()
    }

}
