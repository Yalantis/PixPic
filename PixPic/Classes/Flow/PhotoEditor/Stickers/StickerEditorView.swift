//
//  EffectEditorView.swift
//  PixPic
//
//  Created by anna on 1/27/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class StickerEditorView: UIView {

    fileprivate var touchStart: CGPoint?
    fileprivate var previousPoint: CGPoint?
    fileprivate var deltaAngle: CGFloat?

    fileprivate var resizingControl: StickerEditorViewControl!
    fileprivate var deleteControl: StickerEditorViewControl!
    fileprivate var borderView: BorderView!

    fileprivate var oldBounds: CGRect!
    fileprivate var oldTransform: CGAffineTransform!

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

    func switchControls(toState state: Bool, animated: Bool = false) {
        if animated {
            let controlAlpha: CGFloat = state ? 1 : 0
            UIView.animate(withDuration: 0.3, animations: {
                self.resizingControl.alpha = controlAlpha
                self.deleteControl.alpha = controlAlpha
                self.borderView.alpha = controlAlpha
            })
        } else {
            resizingControl.hidden = !state
            deleteControl.hidden = !state
            borderView.isHidden = !state
        }
    }

    fileprivate func setupDefaultAttributes() {
        borderView = BorderView(frame: bounds)
        addSubview(borderView)

        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTap(_:)))
        deleteControl = StickerEditorViewControl(image: UIImage(named: "btnClose"), gestureRecognizer: singleTap)
        addSubview(deleteControl)

        let panResizeGesture = UIPanGestureRecognizer(target: self, action: #selector(resizeTranslate(_:)))
        resizingControl = StickerEditorViewControl(image: UIImage(named: "btnRotation"),
                                                   gestureRecognizer: panResizeGesture)
        addSubview(resizingControl)

        let pinchResizeGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch(_:)))
        pinchResizeGesture.delegate = self
        addGestureRecognizer(pinchResizeGesture)

        let rotateResizeGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotate(_:)))
        rotateResizeGesture.delegate = self
        addGestureRecognizer(rotateResizeGesture)

        updateControlsPosition()

        deltaAngle = atan2(frame.origin.y + frame.height - center.y, frame.origin.x + frame.width - center.x)
    }

    fileprivate func setupContentView(_ content: UIView) {
        let contentView = UIView(frame: content.frame)
        contentView.backgroundColor = .clear
        contentView.addSubview(content)
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(contentView)

        for subview in contentView.subviews {
            subview.frame = CGRect(x: 0, y: 0, width: contentView.frame.width, height: contentView.frame.height)
            subview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        }
    }
    // MARK: Gestures with controls
    @objc fileprivate func singleTap(_ recognizer: UIPanGestureRecognizer) {
        let close = recognizer.view
        if let close = close {
            close.superview?.removeFromSuperview()
        }
    }

    @objc fileprivate func resizeTranslate(_ recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .began {
            enableTranslucency(true)
            previousPoint = recognizer.location(in: self)
            setNeedsDisplay()

        } else if recognizer.state == .changed {
            resizeView(recognizer)
            rotateView(with: deltaAngle, recognizer: recognizer)

        } else if recognizer.state == .ended {
            enableTranslucency(false)
            previousPoint = recognizer.location(in: self)
            setNeedsDisplay()
        }
        updateControlsPosition()
    }

    fileprivate func resizeView(_ recognizer: UIPanGestureRecognizer) {
        let point = recognizer.location(in: self)
        guard let previousPoint = previousPoint else {
            return
        }
        let diagonal = sqrt(pow(point.x, 2) + pow(point.y, 2))
        let previousDiagonal = sqrt(pow(previousPoint.x, 2) + pow(previousPoint.y, 2))
        let totalRatio = pow(diagonal / previousDiagonal, 2)

        bounds = CGRect(x: 0, y: 0, width: bounds.size.width * totalRatio, height: bounds.size.height * totalRatio)
        self.previousPoint = recognizer.location(in: self)
    }

    fileprivate func rotateView(with deltaAngle: CGFloat?, recognizer: UIPanGestureRecognizer) {
        let angle = atan2(recognizer.location(in: superview).y - center.y,
                          recognizer.location(in: superview).x - center.x)

        if let deltaAngle = deltaAngle {
            let angleDiff = deltaAngle - angle
            transform = CGAffineTransform(rotationAngle: -angleDiff)
        }
    }

    fileprivate func updateControlsPosition() {
        let offset = Constants.StickerEditor.userResizableViewGlobalOffset
        borderView.frame = CGRect(x: -offset, y: -offset, width: bounds.size.width + offset * 2,
                                  height: bounds.size.height + offset * 2)

        deleteControl.center = CGPoint(x: borderView.frame.origin.x, y: borderView.frame.origin.y)
        resizingControl.center = CGPoint(x: borderView.frame.origin.x + borderView.frame.size.width,
                                         y: borderView.frame.origin.y + borderView.frame.size.height)
    }

    // MARK: Gestures without controls
    @objc fileprivate func pinch(_ recognizer: UIPinchGestureRecognizer) {
        if recognizer.state == .began {
            oldBounds = bounds
            enableTranslucency(true)
            previousPoint = recognizer.location(in: self)
            setNeedsDisplay()
        } else if recognizer.state == .changed {
            bounds = CGRect(x: 0, y: 0, width: oldBounds.width * recognizer.scale,
                            height: oldBounds.height * recognizer.scale)
        } else if recognizer.state == .ended {
            oldBounds = bounds
            enableTranslucency(false)
            previousPoint = recognizer.location(in: self)
            setNeedsDisplay()
        }
        updateControlsPosition()
    }

    @objc fileprivate func rotate(_ recognizer: UIRotationGestureRecognizer) {
        if recognizer.state == .began {
            oldTransform = transform
            enableTranslucency(true)
            previousPoint = recognizer.location(in: self)
            setNeedsDisplay()
        } else if recognizer.state == .changed {
            transform = oldTransform.rotated(by: recognizer.rotation)
        } else if recognizer.state == .ended {
            oldTransform = transform
            enableTranslucency(false)
            previousPoint = recognizer.location(in: self)
            setNeedsDisplay()
        }
        updateControlsPosition()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        enableTranslucency(true)

        let touch = touches.first
        if let touch = touch {
            touchStart = touch.location(in: superview)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchLocation = touches.first?.location(in: self)
        if resizingControl.frame.contains(touchLocation!) {
            return
        }

        let touch = touches.first?.location(in: superview)
        translateUsingTouchLocation(touch!)
        touchStart = touch
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        enableTranslucency(false)
    }

    fileprivate func translateUsingTouchLocation(_ touchPoint: CGPoint) {
        if let touchStart = touchStart {
            center = CGPoint(x: center.x + touchPoint.x - touchStart.x, y: center.y + touchPoint.y - touchStart.y)
        }
    }

    fileprivate func enableTranslucency(_ state: Bool) {
        UIView.animate(withDuration: 0.1, animations: {
            if state == true {
                self.alpha = 0.65
            } else {
                self.alpha = 1
            }
        }) 
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if resizingControl.frame.contains(point) ||
            deleteControl.frame.contains(point) ||
            bounds.contains(point) {

            for subview in subviews.reversed() {
                let convertedPoint = subview.convert(point, from: self)
                let hitTestView = subview.hitTest(convertedPoint, with: event)
                if hitTestView != nil {
                    return hitTestView
                }
            }
            return self
        }
        return nil
    }

}

extension StickerEditorView: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKind(of: UIPinchGestureRecognizer.self) &&
            otherGestureRecognizer.isKind(of: UIRotationGestureRecognizer.self) {
            return true
        } else {
            return false
        }
    }

}
