//
//  EffectEditorView.swift
//  P-effect
//
//  Created by anna on 1/27/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class EffectEditorView: UIView {
    
    private var touchStart: CGPoint?
    private var prevPoint: CGPoint?
    private var deltaAngle: CGFloat?
    
    private var resizingControl: UIImageView!
    private var deleteControl: UIImageView!
    private var borderView: BorderView!
    
    init(image: UIImage) {
        let effectImageView = UIImageView(image: image)
        
        super.init(frame: effectImageView.frame)
        
        setupContentView(effectImageView)
        setupDefaultAttributes()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupDefaultAttributes()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupDefaultAttributes()
    }
    
    func switchControls(toState state: Bool) {
        resizingControl.hidden = !state
        deleteControl.hidden = !state
        borderView.hidden = !state
    }
    
    private func setupDefaultAttributes() {
        let borderViewFrame = CGRectInset(bounds,
            Constants.EffectEditor.UserResizableViewGlobalInset,
            Constants.EffectEditor.UserResizableViewGlobalInset)
        
        borderView = BorderView(frame: borderViewFrame)
        addSubview(borderView)
        
        let deleteControlFrame = CGRectMake(0, 0,
            Constants.EffectEditor.StickerViewControlSize,
            Constants.EffectEditor.StickerViewControlSize)
        let deleteControlImage = UIImage(named: "delete_control")
        deleteControl = createControlWithFrame(deleteControlFrame, image: deleteControlImage)
        
        let singleTap = UITapGestureRecognizer(target: self, action: "singleTap:")
        deleteControl.addGestureRecognizer(singleTap)
        addSubview(deleteControl)
        
        let resizingControlFrame = CGRectMake(frame.size.width - Constants.EffectEditor.StickerViewControlSize,
            frame.size.height - Constants.EffectEditor.StickerViewControlSize,
            Constants.EffectEditor.StickerViewControlSize,
            Constants.EffectEditor.StickerViewControlSize)
        let resizingControlImage = UIImage(named: "resize_control")
        resizingControl = createControlWithFrame(resizingControlFrame, image: resizingControlImage)
        
        let panResizeGesture = UIPanGestureRecognizer(target: self, action: "resizeTranslate:")
        resizingControl.addGestureRecognizer(panResizeGesture)
        addSubview(resizingControl)
        
        deltaAngle = atan2(frame.origin.y + frame.size.height - center.y, frame.origin.x + frame.size.width - center.x)
    }
    
    private func setupContentView(content: UIView) {
        let contentView = UIView(frame: content.frame)
        contentView.backgroundColor = UIColor.clearColor()
        contentView.addSubview(content)
        
        contentView.frame = CGRectInset(bounds,
            Constants.EffectEditor.UserResizableViewGlobalInset +
                Constants.EffectEditor.UserResizableViewInteractiveBorderSize / 2,
            Constants.EffectEditor.UserResizableViewGlobalInset +
                Constants.EffectEditor.UserResizableViewInteractiveBorderSize / 2)
        
        contentView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        addSubview(contentView)
        
        for subview in contentView.subviews {
            subview.frame = CGRectMake(0, 0, contentView.frame.size.width, contentView.frame.size.height)
            subview.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        }
    }
    
    dynamic private func singleTap(recognizer: UIPanGestureRecognizer) {
        let close = recognizer.view
        if let close = close {
            close.superview?.removeFromSuperview()
        }
    }
    
    dynamic private func resizeTranslate(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .Began {
            enableTranslucency(true)
            prevPoint = recognizer.locationInView(self)
            setNeedsDisplay()
            
        } else if recognizer.state == .Changed {
            enableTranslucency(true)
            resizeView(recognizer)
            rotateViewWithAngle(angle: deltaAngle, recognizer: recognizer)
            
        } else if recognizer.state == .Ended {
            enableTranslucency(false)
            prevPoint = recognizer.locationInView(self)
            setNeedsDisplay()
        }
    }
    
    private func resizeView(recognizer: UIPanGestureRecognizer) {
        let point = recognizer.locationInView(self)
        
        let wChange = point.x - prevPoint!.x
        let wRatioChange = wChange / bounds.size.width
        let hChange = wRatioChange * bounds.size.height
        
        bounds = CGRectMake(bounds.origin.x,
            bounds.origin.y,
            bounds.size.width + wChange,
            bounds.size.height + hChange)
        
        resizingControl.frame = CGRectMake(bounds.size.width - Constants.EffectEditor.StickerViewControlSize,
            bounds.size.height - Constants.EffectEditor.StickerViewControlSize,
            Constants.EffectEditor.StickerViewControlSize,
            Constants.EffectEditor.StickerViewControlSize)
        
        deleteControl.frame = CGRectMake(0, 0,
            Constants.EffectEditor.StickerViewControlSize,
            Constants.EffectEditor.StickerViewControlSize)
        
        prevPoint = recognizer.locationOfTouch(0, inView: self)
    }
    
    private func rotateViewWithAngle(angle deltaAngle: CGFloat?, recognizer: UIPanGestureRecognizer) {
        let angle = atan2(recognizer.locationInView(superview).y - center.y,
            recognizer.locationInView(superview).x - center.x)
        
        if let deltaAngle = deltaAngle {
            let angleDiff = deltaAngle - angle
            transform = CGAffineTransformMakeRotation(-angleDiff)
        }
        
        borderView.frame = CGRectInset(bounds,
            Constants.EffectEditor.UserResizableViewGlobalInset,
            Constants.EffectEditor.UserResizableViewGlobalInset)
        borderView.setNeedsDisplay()
        setNeedsDisplay()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        enableTranslucency(true)
        
        let touch = touches.first
        if let touch = touch {
            touchStart = touch.locationInView(superview)
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        enableTranslucency(true)
        
        let touchLocation = touches.first?.locationInView(self)
        if CGRectContainsPoint(resizingControl.frame, touchLocation!) {
            return
        }
        
        let touch = touches.first?.locationInView(superview)
        translateUsingTouchLocation(touch!)
        touchStart = touch
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        enableTranslucency(false)
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        enableTranslucency(false)
    }
    
    private func translateUsingTouchLocation(touchPoint: CGPoint) {
        if let touchStart = touchStart {
            center = CGPointMake(center.x + touchPoint.x - touchStart.x, center.y + touchPoint.y - touchStart.y)
        }
    }
    
    private func enableTranslucency(state: Bool) {
        if state == true {
            alpha = 0.65
        } else {
            alpha = 1.0
        }
    }
    
    private func createControlWithFrame(frame: CGRect, image: UIImage?) -> UIImageView {
        let control = UIImageView(frame: frame)
        control.layer.cornerRadius = control.frame.size.width / 2
        control.backgroundColor = UIColor.appWhiteColor
        if let image = image {
            control.image = image
        }
        control.userInteractionEnabled = true
        
        return control
    }
    
}