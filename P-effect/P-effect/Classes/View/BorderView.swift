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
        CGContextAddRect(context, CGRectInset(bounds,
            Constants.EffectEditor.UserResizableViewInteractiveBorderSize / 2,
            Constants.EffectEditor.UserResizableViewInteractiveBorderSize / 2))
        
        CGContextStrokePath(context)
        CGContextRestoreGState(context)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clearColor()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        backgroundColor = UIColor.clearColor()
    }

}
