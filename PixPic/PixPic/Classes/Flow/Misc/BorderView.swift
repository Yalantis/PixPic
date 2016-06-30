//
//  BorderView.swift
//  PixPic
//
//  Created by anna on 1/27/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class BorderView: UIView {
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        CGContextSetLineWidth(context, 1)
    
        let dash: Array<CGFloat> = [4.0, 2.0]
        CGContextSetLineDash(context, 0.0, dash, 2)
        
        CGContextSetStrokeColorWithColor(context, UIColor.whiteColor().CGColor)
        
        CGContextAddRect(context, rect)
        
        CGContextStrokePath(context)
        CGContextRestoreGState(context)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor.clearColor()
    }

}
