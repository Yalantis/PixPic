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
    @nonobjc static let appNavBarColor = UIColor(rgbColorCodeRed: 51, green: 51, blue: 51, alpha: 0.65)
    @nonobjc static let appPurpleColor = UIColor(rgbColorCodeRed: 148, green: 55, blue: 234, alpha: 1)
    @nonobjc static let appWhiteColor = UIColor.whiteColor()
    
    convenience init(rgbColorCodeRed red: Int, green: Int, blue: Int, alpha: CGFloat) {
        let redPart = CGFloat(red) / 255
        let greenPart = CGFloat(green) / 255
        let bluePart = CGFloat(blue) / 255
        
        self.init(red: redPart, green: greenPart, blue: bluePart, alpha: alpha)
    }
}
