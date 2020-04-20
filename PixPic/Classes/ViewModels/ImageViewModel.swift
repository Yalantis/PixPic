//
//  ImageViewModel.swift
//  PixPic
//
//  Created by Illya on 1/26/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class ImageViewModel: NSObject {

    fileprivate let setedOriginalImage: UIImage

    init(image: UIImage) {
        setedOriginalImage = image

        super.init()
    }

    func originalImage() -> UIImage {
        return setedOriginalImage
    }

}
