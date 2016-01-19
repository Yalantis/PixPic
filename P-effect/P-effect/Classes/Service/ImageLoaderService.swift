//
//  ImageLoaderService.swift
//  P-effect
//
//  Created by anna on 1/19/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

typealias LoadingImageComplition = (image: UIImage, error: NSError?) -> ()

class ImageLoaderService: NSObject {
    
    func getImageForContentItem(content: PFFile?, complition: LoadingImageComplition) {
        if let content = content {
            content.getDataInBackgroundWithBlock { data, error in
                if let data = data {
                    if let image = UIImage(data: data) {
                        complition(image: image, error: error)
                    }
                }
            }
        }
    }

}
