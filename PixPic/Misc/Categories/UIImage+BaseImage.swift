//
//  UIImage+BaseImage.swift
//  PixPic
//
//  Created by Jack Lapin on 02.02.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

extension UIImage {

    static var appBackButton: UIImage? {
        return UIImage(named: "backArrow")
    }

    static var placeholderImage: UIImage? {
        return UIImage(named: "noPhotoPlaceholder")
    }

    static var stickerPlaceholderImage: UIImage? {
        return UIImage(named: "placeholder")
    }

    static var avatarPlaceholderImage: UIImage? {
        return UIImage(named: "profile_placeholder")
    }

    static var appAddPhotoButton: UIImage? {
        return UIImage(named: "btn_make_photo")
    }

    public static func imageFromColor(_ color: UIColor, size: CGSize) -> UIImage? {
        let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContext(rect.size)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return image
    }

}
