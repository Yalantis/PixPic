//
//  UIView+Effects.swift
//  PixPic
//
//  Created by Jack Lapin on 03.02.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import Foundation

@IBDesignable
extension UIView {

    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }

    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }

    @IBInspectable var borderColor: UIColor {
        set {
            layer.borderColor = newValue.cgColor
        }
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
    }

    @IBInspectable var shadowOffset: CGSize {
        set {
            layer.shadowOffset = newValue
        }
        get {
            return layer.shadowOffset
        }
    }

    @IBInspectable var shadowOpacity: Float {
        set {
            layer.shadowOpacity = newValue
        }
        get {
            return layer.shadowOpacity
        }
    }

    @IBInspectable var shadowRadius: CGFloat {
        set {
            layer.shadowRadius = newValue
        }
        get {
            return layer.shadowRadius
        }
    }

    @IBInspectable var shadowColor: UIColor {
        set {
            layer.shadowColor = newValue.cgColor
        }
        get {
            return UIColor(cgColor: layer.shadowColor!)
        }
    }

    @IBInspectable var clipToBounds: Bool {
        set {
            clipsToBounds = newValue
        }
        get {
            return clipsToBounds
        }
    }

}
