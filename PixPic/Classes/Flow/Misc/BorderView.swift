//
//  BorderView.swift
//  PixPic
//
//  Created by anna on 1/27/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class BorderView: UIView {

    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        context?.setLineWidth(1)

        let dash: Array<CGFloat> = [4.0, 2.0]
        CGContextSetLineDash(context, 0.0, dash, 2)

        context?.setStrokeColor(UIColor.white.cgColor)

        context?.addRect(rect)

        context?.strokePath()
        context?.restoreGState()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupView()
    }

    fileprivate func setupView() {
        backgroundColor = UIColor.clear
    }

}
