//
//  File.swift
//  PixPic
//
//  Created by AndrewPetrov on 2/8/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

@IBDesignable
extension UICollectionViewFlowLayout {

    @IBInspectable var pin: Bool {
        set {
            sectionHeadersPinToVisibleBounds = newValue
        }
        get {
            return sectionHeadersPinToVisibleBounds
        }
    }

}
