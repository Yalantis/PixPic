//
//  ImageLoaderService.swift
//  PixPic
//
//  Created by anna on 1/19/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

typealias LoadingImageCompletion = (image: UIImage?, error: NSError?) -> Void

extension PFFile {
    
    func getImage(completion: LoadingImageCompletion) {
        getDataInBackgroundWithBlock { data, error in
            if let data = data, let image = UIImage(data: data){
                completion(image: image, error: error)
            }
        }
    }
    
}
