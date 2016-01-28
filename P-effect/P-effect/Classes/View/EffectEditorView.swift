//
//  EffectEditorView.swift
//  P-effect
//
//  Created by anna on 1/27/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class EffectEditorView: UIView {
    
    private let kUserResizableViewGlobalInset: CGFloat =  5.0
    private let kUserResizableViewDefaultMinWidth: CGFloat =  48.0
    
    private let kUserResizableViewInteractiveBorderSize: CGFloat =  10.0
    private let kStickerViewControlSize: CGFloat =  36.0
    
    private var touchStart: CGPoint?
    private var prevPoint: CGPoint?
    private var deltaAngle: CGFloat!
    
    private var minWidth: CGFloat?
    private var minHeight: CGFloat?
    
    private var resizingControl: UIImageView!
    private var deleteControl: UIImageView!
    private var borderView: BorderView!
    
    init(image: UIImage) {
        let effectImageView = UIImageView(image: image)
        
        super.init(frame: effectImageView.frame)
        
        setupDefaultAttributes()
        setupContentView(effectImageView)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupDefaultAttributes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupDefaultAttributes()
    }
    
    private func setupDefaultAttributes() {
        borderView = BorderView(frame: CGRectInset(bounds,
            kUserResizableViewGlobalInset,
            kUserResizableViewGlobalInset))
        
        addSubview(borderView!)
        
        if (kUserResizableViewDefaultMinWidth > bounds.size.width / 2) {
            minWidth = kUserResizableViewDefaultMinWidth
            minHeight = bounds.size.height * (kUserResizableViewDefaultMinWidth / self.bounds.size.width)
        } else {
            minWidth = bounds.size.width / 2
            minHeight = bounds.size.height / 2
        }
        
        deleteControl = UIImageView(frame: CGRectMake(0, 0,
            kStickerViewControlSize,
            kStickerViewControlSize))
        
        deleteControl.backgroundColor = UIColor.whiteColor()
        deleteControl.image = UIImage(named: "delete_50")
        deleteControl.userInteractionEnabled = true
        
        addSubview(deleteControl!)
        
        resizingControl = UIImageView(frame: CGRectMake(frame.size.width - kStickerViewControlSize,
            frame.size.height - kStickerViewControlSize,
            kStickerViewControlSize,
            kStickerViewControlSize))
        
        resizingControl.backgroundColor = UIColor.whiteColor()
        resizingControl.image = UIImage(named: "delete_50")
        resizingControl.userInteractionEnabled = true
        
        addSubview(resizingControl!)
        
        deltaAngle = atan2(frame.origin.y + frame.size.height - center.y, frame.origin.x + frame.size.width - center.x)
    }
    
    private func setupContentView(content: UIView) {
        let contentView = UIView(frame: content.frame)
        contentView.backgroundColor = UIColor.clearColor()
        contentView.addSubview(content)
        
        contentView.frame = CGRectInset(bounds,
            kUserResizableViewGlobalInset + kUserResizableViewInteractiveBorderSize / 2,
            kUserResizableViewGlobalInset + kUserResizableViewInteractiveBorderSize / 2)
        
        contentView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        addSubview(contentView)
        
        for subview in contentView.subviews {
            subview.frame = CGRectMake(0, 0, contentView.frame.size.width, contentView.frame.size.height)
            subview.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        }
        
        bringSubviewToFront(borderView)
        bringSubviewToFront(deleteControl)
        bringSubviewToFront(resizingControl)
    }
    
}