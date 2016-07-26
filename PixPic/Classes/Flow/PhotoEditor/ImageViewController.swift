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
    
    private weak var locator: ServiceLocator!
    private var stickers = [StickerEditorView]()
    
    @IBOutlet private weak var rawImageView: UIImageView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rawImageView.image = model.originalImage()
    }
    
    // MARK: - Setup methods
    func setLocator(locator: ServiceLocator) {
        self.locator = locator
    }
    
}

// MARK: - PhotoEditorDelegate methods
extension ImageViewController: PhotoEditorDelegate {
    
    func photoEditor(photoEditor: PhotoEditorViewController, didChooseSticker: UIImage) {
        let userResizableView = StickerEditorView(image: didChooseSticker)
        userResizableView.center = rawImageView.center
        rawImageView.addSubview(userResizableView)
        stickers.append(userResizableView)
    }
    
    func imageForPhotoEditor(photoEditor: PhotoEditorViewController, withStickers: Bool) -> UIImage {
        guard withStickers else {
            return rawImageView.image!
        }
        
        for sticker in stickers {
            sticker.switchControls(toState: false)
        }
        let rect = rawImageView.bounds
        UIGraphicsBeginImageContextWithOptions(rect.size, view.opaque, 0)
        rawImageView.drawViewHierarchyInRect(rect, afterScreenUpdates: true)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        for sticker in stickers {
            sticker.switchControls(toState: true)
        }
        
        return image
    }
    
    func removeAllStickers(photoEditor: PhotoEditorViewController) {
        for sticker in stickers {
            sticker.removeFromSuperview()
        }
    }
    
}