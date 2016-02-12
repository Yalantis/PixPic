//
//  UIColor+BaseColor.swift
//  P-effect
//
//  Created by Jack Lapin on 02.02.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(hexString: String) {
        // String -> UInt32
        var rgbValue: UInt32 = 0
        NSScanner(string: hexString).scanHexInt(&rgbValue)
        
        // UInt32 -> R,G,B
        let red = CGFloat((rgbValue >> 16) & 0xff) / 255.0
        let green = CGFloat((rgbValue >> 08) & 0xff) / 255.0
        let blue = CGFloat((rgbValue >> 00) & 0xff) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
}

extension UIColor {
    
    // MARK: - Base colors
    @nonobjc static let appBaseDarkColor = UIColor(hexString: "333333")
    
    @nonobjc static let appNavBarColor = UIColor.init(red: 51/255, green: 51/255, blue: 51/255, alpha: 0.65)
    
    @nonobjc static let appBlueColor = UIColor.init(red: 0/255, green: 97/255, blue: 221/255, alpha: 1)
    
}
