//
//  BorderView.swift
//  P-effect
//
//  Created by anna on 1/27/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class BorderView: UIView {
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        CGContextSetLineWidth(context, 1.0)
        
        CGContextSetStrokeColorWithColor(context, UIColor.grayColor().CGColor)
        
        let borderRect = CGRectInset(bounds,
            Constants.StickerEditor.UserResizableViewInteractiveBorderSize,
            Constants.StickerEditor.UserResizableViewInteractiveBorderSize)
        
        CGContextAddRect(context, borderRect)
        
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
