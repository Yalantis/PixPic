//
//  UIImage+BaseImage.swift
//  P-effect
//
//  Created by Jack Lapin on 02.02.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

extension UIImage {
    
    @nonobjc static let appBackButton = UIImage(named: "back_arrow")
    @nonobjc static let placeholderImage = UIImage(named: "photo_placeholder")
    @nonobjc static let avatarPlaceholderImage = UIImage(named: "profile_placeholder")
    @nonobjc static let appAddPhotoButton = UIImage(named: "btn_make_photo")
    
    public static func imageFromColor(color: UIColor, size: CGSize) -> UIImage? {
        let rect = CGRectMake(0.0, 0.0, size.width, size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context: CGContextRef = UIGraphicsGetCurrentContext()!
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
}
