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
        
        let singleTap = UITapGestureRecognizer(target: self, action: "singleTap:")
        deleteControl?.addGestureRecognizer(singleTap)
        
        addSubview(deleteControl!)
        
        resizingControl = UIImageView(frame: CGRectMake(frame.size.width - kStickerViewControlSize,
            frame.size.height - kStickerViewControlSize,
            kStickerViewControlSize,
            kStickerViewControlSize))
        
        resizingControl.backgroundColor = UIColor.whiteColor()
        resizingControl.image = UIImage(named: "delete_50")
        resizingControl.userInteractionEnabled = true
        
        let panResizeGesture = UIPanGestureRecognizer(target: self, action: "resizeTranslate:")
        resizingControl?.addGestureRecognizer(panResizeGesture)

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
    
    dynamic private func singleTap(recognizer: UIPanGestureRecognizer) {
        let close = recognizer.view
        close!.superview!.removeFromSuperview()
    }
    
    dynamic private func resizeTranslate(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .Began {
            enableTransluceny(state: true)
            prevPoint = recognizer.locationInView(self)
            setNeedsDisplay()
        } else if recognizer.state == .Changed {
            enableTransluceny(state: true)
            
            // preventing from the picture being shrinked too far by resizing
            if bounds.size.width < minWidth || self.bounds.size.height < minHeight {
                
                bounds = CGRectMake(bounds.origin.x, bounds.origin.y, minWidth! + 1, minHeight! + 1)
                resizingControl.frame = CGRectMake(bounds.size.width - kStickerViewControlSize,
                    bounds.size.height-kStickerViewControlSize,
                    kStickerViewControlSize,
                    kStickerViewControlSize)
                
                deleteControl.frame = CGRectMake(0, 0, kStickerViewControlSize, kStickerViewControlSize);
                prevPoint = recognizer.locationInView(self)
                
            } else {
                // Resizing
                
                let point = recognizer.locationInView(self)
                var wChange: CGFloat = 0.0, hChange: CGFloat = 0.0
                
                wChange = (point.x - prevPoint!.x) as CGFloat
                let wRatioChange = wChange / bounds.size.width
                
                hChange = wRatioChange * self.bounds.size.height;
                
                if abs(wChange) > 50.0 || abs(hChange) > 50.0 {
                    prevPoint = recognizer.locationOfTouch(0, inView: self)
                    return
                }
                
                bounds = CGRectMake(bounds.origin.x,
                    bounds.origin.y,
                    bounds.size.width + wChange,
                    bounds.size.height + hChange)
                
                resizingControl.frame = CGRectMake(bounds.size.width - kStickerViewControlSize,
                    bounds.size.height - kStickerViewControlSize,
                    kStickerViewControlSize,
                    kStickerViewControlSize)
                
                deleteControl.frame = CGRectMake(0, 0, kStickerViewControlSize, kStickerViewControlSize)
                
                prevPoint = recognizer.locationOfTouch(0, inView: self)
            }
            // Rotation
            
            let angle = atan2(recognizer.locationInView(superview).y - center.y,
                recognizer.locationInView(superview).x - center.x)
            
            let angleDiff = deltaAngle - angle
            
            transform = CGAffineTransformMakeRotation(-angleDiff);
            
            borderView.frame = CGRectInset(bounds, kUserResizableViewGlobalInset, kUserResizableViewGlobalInset)
            borderView.setNeedsDisplay()
            setNeedsDisplay()
            
        } else if recognizer.state == .Ended {
            enableTransluceny(state: false)
            prevPoint = recognizer.locationInView(self)
            setNeedsDisplay()
        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        enableTransluceny(state: true)
        
        let touch = touches.first
        if let touch = touch {
            touchStart = touch.locationInView(superview)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        enableTransluceny(state: true)
        
        let touchLocation = touches.first?.locationInView(self)
        if CGRectContainsPoint(resizingControl.frame, touchLocation!) {
            return
        }
        
        let touch = touches.first?.locationInView(superview)
        translateUsingTouchLocation(touch!)
        touchStart = touch
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        enableTransluceny(state: false)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        enableTransluceny(state: false)
    }
    
    private func translateUsingTouchLocation(touchPoint: CGPoint) {
        var newCenter = CGPointMake(center.x + touchPoint.x - touchStart!.x, center.y + touchPoint.y - touchStart!.y)
        
        let midPointX = CGRectGetMidX(bounds)
        if newCenter.x > (superview?.bounds.size.width)! - midPointX {
            newCenter.x = (superview?.bounds.size.width)! - midPointX
        }
        
        if newCenter.x < midPointX {
            newCenter.x = midPointX
        }
        
        let midPointY = CGRectGetMidY(bounds)
        if newCenter.y > (superview?.bounds.size.height)! - midPointY {
            newCenter.y = (superview?.bounds.size.height)! - midPointY
        }
        
        if newCenter.y < midPointY {
            newCenter.y = midPointY
        }
        
        center = newCenter
    }

    
    private func enableTransluceny(state state: Bool) {
        if state == true {
            alpha = 0.65
        } else {
            alpha = 1.0
        }
    }

}