//
//  EffectEditorView.swift
//  P-effect
//
//  Created by anna on 1/27/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class StickerEditorView: UIView {
    
    private var touchStart: CGPoint?
    private var previousPoint: CGPoint?
    private var deltaAngle: CGFloat?
    
    private var resizingControl: UIImageView!
    private var deleteControl: UIImageView!
    private var borderView: BorderView!
    
    init(image: UIImage) {
        let stickerImageView = UIImageView(image: image)
        
        super.init(frame: stickerImageView.frame)
        
        setupContentView(stickerImageView)
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
            Constants.StickerEditor.UserResizableViewGlobalInset,
            Constants.StickerEditor.UserResizableViewGlobalInset)
        
        borderView = BorderView(frame: borderViewFrame)
        addSubview(borderView)
        
        let deleteControlFrame = CGRectMake(0, 0,
            Constants.StickerEditor.StickerViewControlSize,
            Constants.StickerEditor.StickerViewControlSize)
        let deleteControlImage = UIImage(named: "delete_control")
        deleteControl = createControlWithFrame(deleteControlFrame, image: deleteControlImage)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTap(_:)))
        deleteControl.addGestureRecognizer(singleTap)
        addSubview(deleteControl)
        
        let resizingControlFrame = CGRectMake(frame.size.width - Constants.StickerEditor.StickerViewControlSize,
            frame.size.height - Constants.StickerEditor.StickerViewControlSize,
            Constants.StickerEditor.StickerViewControlSize,
            Constants.StickerEditor.StickerViewControlSize)
        let resizingControlImage = UIImage(named: "resize_control")
        resizingControl = createControlWithFrame(resizingControlFrame, image: resizingControlImage)
        
        let panResizeGesture = UIPanGestureRecognizer(target: self, action: #selector(resizeTranslate(_:)))
        resizingControl.addGestureRecognizer(panResizeGesture)
        addSubview(resizingControl)
        
        deltaAngle = atan2(frame.origin.y + frame.height - center.y, frame.origin.x + frame.width - center.x)
    }
    
    private func setupContentView(content: UIView) {
        let contentView = UIView(frame: content.frame)
        contentView.backgroundColor = UIColor.clearColor()
        contentView.addSubview(content)
        
        contentView.frame = CGRectInset(bounds,
            Constants.StickerEditor.UserResizableViewGlobalInset +
                Constants.StickerEditor.UserResizableViewInteractiveBorderSize,
            Constants.StickerEditor.UserResizableViewGlobalInset +
                Constants.StickerEditor.UserResizableViewInteractiveBorderSize)
        
        contentView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        addSubview(contentView)
        
        for subview in contentView.subviews {
            subview.frame = CGRectMake(0, 0, contentView.frame.width, contentView.frame.height)
            subview.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        }
    }
    
    @objc private func singleTap(recognizer: UIPanGestureRecognizer) {
        let close = recognizer.view
        if let close = close {
            close.superview?.removeFromSuperview()
        }
    }
    
    @objc private func resizeTranslate(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .Began {
            enableTranslucency(true)
            previousPoint = recognizer.locationInView(self)
            setNeedsDisplay()
            
        } else if recognizer.state == .Changed {
            enableTranslucency(true)
            resizeView(recognizer)
            rotateViewWithAngle(angle: deltaAngle, recognizer: recognizer)
            
        } else if recognizer.state == .Ended {
            enableTranslucency(false)
            previousPoint = recognizer.locationInView(self)
            setNeedsDisplay()
        }
    }
    
    private func resizeView(recognizer: UIPanGestureRecognizer) {
        let point = recognizer.locationInView(self)
        guard let previousWidth = previousPoint?.x else {
            return
        }
        let widthChange = point.x - previousWidth
        let widthRatioChange = widthChange / bounds.size.width
        let heightChange = widthRatioChange * bounds.size.height
        
        bounds = CGRectMake(bounds.origin.x,
            bounds.origin.y,
            bounds.size.width + widthChange,
            bounds.size.height + heightChange)
        
        resizingControl.frame = CGRectMake(bounds.size.width - Constants.StickerEditor.StickerViewControlSize,
            bounds.size.height - Constants.StickerEditor.StickerViewControlSize,
            Constants.StickerEditor.StickerViewControlSize,
            Constants.StickerEditor.StickerViewControlSize)
        
        deleteControl.frame = CGRectMake(0, 0,
            Constants.StickerEditor.StickerViewControlSize,
            Constants.StickerEditor.StickerViewControlSize)
        
        previousPoint = recognizer.locationOfTouch(0, inView: self)
    }
    
    private func rotateViewWithAngle(angle deltaAngle: CGFloat?, recognizer: UIPanGestureRecognizer) {
        let angle = atan2(recognizer.locationInView(superview).y - center.y,
            recognizer.locationInView(superview).x - center.x)
        
        if let deltaAngle = deltaAngle {
            let angleDiff = deltaAngle - angle
            transform = CGAffineTransformMakeRotation(-angleDiff)
        }
        
        borderView.frame = CGRectInset(bounds,
            Constants.StickerEditor.UserResizableViewGlobalInset,
            Constants.StickerEditor.UserResizableViewGlobalInset)
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
        control.layer.cornerRadius = control.frame.width / 2
        control.backgroundColor = UIColor.appWhiteColor
        if let image = image {
            control.image = image
        }
        control.userInteractionEnabled = true
        
        return control
    }
    
}