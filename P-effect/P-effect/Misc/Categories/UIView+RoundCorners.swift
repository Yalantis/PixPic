//
//  UIView+RoundCorners.swift
//  AchievementStore
//
//  Created by Dmitriy Demchenko on 1/12/16.
//  Copyright © 2016 Konstantin Safronov. All rights reserved.
//

import Foundation

extension UIView {
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.CGPath
        layer.mask = mask
    }
}