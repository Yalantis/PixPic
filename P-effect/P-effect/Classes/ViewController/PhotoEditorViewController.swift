//
//  PhotoEditorViewController.swift
//  P-effect
//
//  Created by Illya on 1/25/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import Photos

protocol PhotoEditorDelegate: class {
    
    func photoEditor(photoEditor: PhotoEditorViewController, didChooseEffect: UIImage)
    func imageForPhotoEditor(photoEditor: PhotoEditorViewController, withEffects: Bool) -> UIImage
    
}

final class PhotoEditorViewController: UIViewController, StoryboardInitable {
    
    internal static let storyboardName = Constants.Storyboard.PhotoEditor

    var model: PhotoEditorModel!
    
    var router: PhotoEditorRouter!
    weak var delegate: PhotoEditorDelegate?
    
    private var imageController: ImageViewController?
    private var effectsPickerController: EffectsPickerViewController? {
        didSet {
            effectsPickerController?.delegate = self
        }
    }
    
    @IBOutlet private weak var effectsPickerContainer: UIView!
    @IBOutlet private weak var imageContainer: UIView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigavionBar()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        AlertService.sharedInstance.delegate = router
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        PushNotificationQueue.handleNotificationQueue()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
        case Constants.PhotoEditor.ImageViewControllerSegue:
            imageController = segue.destinationViewController as? ImageViewController
            imageController?.model = ImageViewModel(image: model.originalImage())
            delegate = imageController
            
        case Constants.PhotoEditor.EffectsPickerSegue:
            effectsPickerController = segue.destinationViewController as? EffectsPickerViewController
            effectsPickerController?.effectsPickerAdapter = EffectsPickerAdapter()
            
        default:
            super.prepareForSegue(segue, sender: sender)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        layoutImageContainer()
        layoutEffectsPickerContainer()
        view.layoutIfNeeded()
    }
    
    func didChooseEffectFromPicket(effect: UIImage) {
        delegate?.photoEditor(self, didChooseEffect: effect)
    }
    
}

// MARK: - Private methods
extension PhotoEditorViewController {
    
    private func setupNavigavionBar() {
        navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(
            image: UIImage.appBackButton(),
            style: .Plain,
            target: self,
            action: "performBackNavigation"
        )
        navigationItem.leftBarButtonItem = newBackButton
        
        let saveButton = UIBarButtonItem(
            title: "Save",
            style: .Plain,
            target: self,
            action: "saveImageToCameraRoll"
        )
        navigationItem.rightBarButtonItem = saveButton
        
        navigationItem.title = "Edit"
    }
    
    private func layoutImageContainer() {
        var size = imageContainer.frame.size
        size.width = view.bounds.width
        size.height = size.width
        imageContainer.bounds.size = size
    }
    
    private func layoutEffectsPickerContainer() {
        var size = effectsPickerContainer.frame.size
        size.width = view.bounds.width
        effectsPickerContainer.bounds.size = size
    }
    
    private dynamic func performBackNavigation() {
        let alertController = UIAlertController(
            title: "Results wasn't saved",
            message: "Do you want to save result to the photo library?",
            preferredStyle: .ActionSheet
        )
        
        let saveAction = UIAlertAction(title: "Save", style: .Default) { [weak self] _ in
            guard let this = self else {
                return
            }
            this.saveImageToCameraRoll()
            this.navigationController!.popViewControllerAnimated(true)
        }
        alertController.addAction(saveAction)
        
        let dontSaveAction = UIAlertAction(title: "Don't save", style: .Default) { [weak self] _ in
            self?.navigationController!.popViewControllerAnimated(true)
        }
        alertController.addAction(dontSaveAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    private dynamic func saveImageToCameraRoll() {
        guard let image = delegate?.imageForPhotoEditor(self, withEffects: true) else {
            ExceptionHandler.handle(Exception.CantApplyEffects)
            
            return
        }
        
        PHPhotoLibrary.requestAuthorization { status in
            dispatch_async(dispatch_get_main_queue()) {
                switch status {
                case .Authorized:
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    AlertService.sharedInstance.delegate?.showSimpleAlert("Image saved to library")
                    
                default:
                    AlertService.sharedInstance.delegate?.showSimpleAlert("No access to photo library")
                }
            }
        }
    }
    
    private func postToFeed() {
        do {
            guard let image = delegate?.imageForPhotoEditor(self, withEffects: true) else {
                throw Exception.CantApplyEffects
            }
            let pictureData = UIImageJPEGRepresentation(image, 0.9)!
            guard let file = PFFile(name: "image", data: pictureData) else {
                throw Exception.CantCreateParseFile
            }
            let postService: PostService = router.locator.getService()
            postService.savePost(file)
            navigationController!.popViewControllerAnimated(true)
        } catch let exception {
            ExceptionHandler.handle(exception as! Exception)
        }
    }
    
    private func suggestSaveToCameraRoll() {
        let alertController = UIAlertController(
            title: Exception.NoConnection.rawValue,
            message: "Would you like to save results to photo library or post after internet access appears?",
            preferredStyle: .ActionSheet
        )
        
        let saveAction = UIAlertAction(title: "Save now", style: .Default) { [weak self] _ in
            self?.saveImageToCameraRoll()
        }
        alertController.addAction(saveAction)
        
        let postAction = UIAlertAction(title: "Post with delay", style: .Default) { [weak self] _ in
            self?.postToFeed()
        }
        alertController.addAction(postAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }

}

// MARK: - IBActions
extension PhotoEditorViewController {
    
    @IBAction private func postEditedImage() {
        guard ReachabilityHelper.checkConnection(showAlert: false) else {
            suggestSaveToCameraRoll()
            
            return
        }
        postToFeed()
    }
    
}
