//
//  ImageLoaderService.swift
//  P-effect
//
//  Created by anna on 1/19/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

typealias LoadingImageCompletion = (image: UIImage?, error: NSError?) -> ()

class ImageLoaderService {
    
    static func getImageForContentItem(content: PFFile, completion: LoadingImageCompletion) {
        content.getDataInBackgroundWithBlock { data, error in
            if let data = data, let image = UIImage(data: data){
                completion(image: image, error: error)
            }
        }
    }
    
}
