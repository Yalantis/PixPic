//
//  UIColor+BaseColor.swift
//  PixPic
//
//  Created by Jack Lapin on 02.02.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

extension UIColor {

    // MARK: - Base colors
    static func appNavBarColor() -> UIColor {
        return UIColor(rgbColorCodeRed: 46, green: 46, blue: 46, alpha: 1)
    }

    static func appTintColor() -> UIColor {
        return UIColor(rgbColorCodeRed: 148, green: 55, blue: 234, alpha: 1)
    }

    static func appWhiteColor() -> UIColor {
        return UIColor.white
    }

    static func appPinkColor() -> UIColor {
        return UIColor(rgbColorCodeRed: 255, green: 8, blue: 190, alpha: 1)
    }

    convenience init(rgbColorCodeRed red: Int, green: Int, blue: Int, alpha: CGFloat) {
        let redPart = CGFloat(red) / 255
        let greenPart = CGFloat(green) / 255
        let bluePart = CGFloat(blue) / 255

        self.init(red: redPart, green: greenPart, blue: bluePart, alpha: alpha)
    }
    
}
