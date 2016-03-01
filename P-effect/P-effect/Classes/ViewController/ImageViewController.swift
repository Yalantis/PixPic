//
//  ImageViewController.swift
//  P-effect
//
//  Created by Illya on 1/26/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    
    var model: ImageViewModel!
    
    @IBOutlet private weak var rawImage: UIImageView!
    
    private var effects = [EffectEditorView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rawImage.image = model.originalImage()
        // Do any additional setup after loading the view.
    }
    
}

extension ImageViewController: PhotoEditorDelegate {
    
    func photoEditor(photoEditor: PhotoEditorViewController, didChooseEffect: UIImage) {
        let userResizableView = EffectEditorView(image: didChooseEffect)
        userResizableView.center = rawImage.center
        rawImage.addSubview(userResizableView)
        effects.append(userResizableView)
    }
    
    func imageForPhotoEditor(photoEditor: PhotoEditorViewController, withEffects: Bool) -> UIImage {
        guard withEffects else {
            return rawImage.image!
        }
        
        for effect in effects {
            effect.switchControls(toState: false)
        }
        let rect = rawImage.bounds
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        rawImage.layer.renderInContext(context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        for effect in effects {
            effect.switchControls(toState: true)
        }
        
        return image
    }
    
    func removeAllEffects(photoEditor: PhotoEditorViewController) {
        for effect in effects {
            effect.removeFromSuperview()
        }
    }
    
}