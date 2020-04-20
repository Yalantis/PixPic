//
//  ImageViewController.swift
//  PixPic
//
//  Created by Illya on 1/26/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {

    var model: ImageViewModel!

    fileprivate weak var locator: ServiceLocator!
    fileprivate var stickers = [StickerEditorView]()
    fileprivate var isControlsVisible = true

    @IBOutlet fileprivate weak var rawImageView: UIImageView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        rawImageView.image = model.originalImage()
        addHideControlsGestureRecognizer()
    }

    // MARK: - Setup methods
    func setLocator(_ locator: ServiceLocator) {
        self.locator = locator
    }

    @objc fileprivate func toggleControlsState() {
        isControlsVisible = !isControlsVisible
        for sticker in stickers {
            sticker.switchControls(toState: isControlsVisible, animated:  true)
        }
    }
    
    fileprivate func addHideControlsGestureRecognizer() {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(toggleControlsState))
        singleTap.delegate = self
        rawImageView.addGestureRecognizer(singleTap)
    }

}

extension ImageViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        for sticker in stickers {
            let touchLocation = touch.location(in: sticker)
            if sticker.bounds.contains(touchLocation) {
                return false
            }
        }
        return true
    }
    
}

// MARK: - PhotoEditorDelegate methods
extension ImageViewController: PhotoEditorDelegate {

    func photoEditor(_ photoEditor: PhotoEditorViewController, didChooseSticker: UIImage) {
        let userResizableView = StickerEditorView(image: didChooseSticker)
        userResizableView.center = rawImageView.center
        rawImageView.addSubview(userResizableView)
        stickers.append(userResizableView)
    }

    func imageForPhotoEditor(_ photoEditor: PhotoEditorViewController, withStickers: Bool) -> UIImage {
        guard withStickers else {
            return rawImageView.image!
        }

        for sticker in stickers {
            sticker.switchControls(toState: false)
        }
        let rect = rawImageView.bounds
        UIGraphicsBeginImageContextWithOptions(rect.size, view.isOpaque, 0)
        rawImageView.drawHierarchy(in: rect, afterScreenUpdates: true)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        for sticker in stickers {
            sticker.switchControls(toState: true)
        }

        return image!
    }

    func removeAllStickers(_ photoEditor: PhotoEditorViewController) {
        for sticker in stickers {
            sticker.removeFromSuperview()
        }
    }

}
