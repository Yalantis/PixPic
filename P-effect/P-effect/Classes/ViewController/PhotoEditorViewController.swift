//
//  PhotoEditorViewController.swift
//  P-effect
//
//  Created by Illya on 1/25/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

protocol PhotoEditorDelegate: class {
    
    func photoEditor(photoEditor: PhotoEditorViewController, didChooseEffect: UIImage)
    func imageForPhotoEditor(photoEditor: PhotoEditorViewController, withEffects: Bool) -> UIImage
    
}

class PhotoEditorViewController: UIViewController {
    
    @IBOutlet private weak var effectsPickerContainer: UIView!
    @IBOutlet private weak var imageContainer: UIView!
    @IBOutlet private weak var leftToolbarButton: UIBarButtonItem!
    @IBOutlet private weak var rightToolbarButton: UIBarButtonItem!
    
    var model: PhotoEditorModel!
    var effectsPickerController: EffectsPickerViewController? {
        didSet {
            effectsPickerController?.delegate = self
        }
    }
    var imageController: ImageViewController?
    weak var delegate: PhotoEditorDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: .Plain, target: self, action: "back:")
        self.navigationItem.leftBarButtonItem = newBackButton;
    }
    
    func back(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Results didn't saved", message: "Would you like to save results to the photo library?", preferredStyle: .ActionSheet)
        
        let saveAction = UIAlertAction(title: "Save", style: .Default) { (action) in
            self.saveToImageLibrary(nil)
            self.navigationController?.popViewControllerAnimated(true)
        }
        alertController.addAction(saveAction)
        
        let DontSaveAction = UIAlertAction(title: "Don't save", style: .Default) { (action) in
            self.navigationController?.popViewControllerAnimated(true)
        }
        alertController.addAction(DontSaveAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction private func postEditedImage(sender: AnyObject) {
        let reachability: Reachability
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            print("Unable to create Reachability")
            
            return
        }
        if reachability.isReachable() {
            guard let image = delegate?.imageForPhotoEditor(self, withEffects: true) else {
                return
            }
            let pictureData = UIImageJPEGRepresentation(image, 0.5)
            guard let file = PFFile(name: "image", data: pictureData!) else {
                return
            }
            let saver = SaverService()
            saver.saveAndUploadPost(file, comment: nil)
            navigationController?.popViewControllerAnimated(true)
        } else {
            let message = reachability.currentReachabilityStatus.description
            let alertController = UIAlertController(title: message, message: "Would you like to save results to photo library?", preferredStyle: .ActionSheet)
            
            let saveAction = UIAlertAction(title: "Save", style: .Default) { (action) in
                self.saveToImageLibrary(nil)
            }
            alertController.addAction(saveAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction private func saveToImageLibrary(sender: AnyObject?) {
        guard let image = delegate?.imageForPhotoEditor(self, withEffects: true) else {
            return
        }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        AlertService.simpleAlert("Image saved to library")
    }
    
    func didChooseEffectFromPicket(effect: UIImage) {
        delegate?.photoEditor(self, didChooseEffect: effect)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        var size = imageContainer.frame.size
        size.width = UIScreen.mainScreen().bounds.width
        size.height = size.width
        imageContainer.bounds.size = size
        size.height = effectsPickerContainer.frame.height
        effectsPickerContainer.bounds.size = size
        
        leftToolbarButton.width = UIScreen.mainScreen().bounds.width * 0.5
        rightToolbarButton.width = UIScreen.mainScreen().bounds.width * 0.5
        view.superview?.layoutIfNeeded()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case Constants.PhotoEditor.ImageViewControllerSegue:
            imageController = segue.destinationViewController as? ImageViewController
            imageController?.model = ImageViewModel.init(image: model.originalImage())
            delegate = imageController
        case Constants.PhotoEditor.EffectsPickerSegue:
            effectsPickerController = segue.destinationViewController as? EffectsPickerViewController
            effectsPickerController?.model = EffectsPickerModel()
        default:
            break
        }
        
        super.prepareForSegue(segue, sender: sender)
    }
}
