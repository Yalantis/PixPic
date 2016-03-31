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
    
    func photoEditor(photoEditor: PhotoEditorViewController, didChooseSticker: UIImage)
    func imageForPhotoEditor(photoEditor: PhotoEditorViewController, withStickers: Bool) -> UIImage
    func removeAllStickers(photoEditor: PhotoEditorViewController)
    
}

private let cancelActionTitle = "Cancel"
private let postActionTitle = "Post with delay"
private let saveActionTitle = "Save"
private let dontSaveActionTitle = "Don't save"

private let suggestSaveToCameraRollMessage = "Would you like to save results to photo library or post after internet access appears?"

final class PhotoEditorViewController: UIViewController, StoryboardInitable, NavigationControllerAppearanceContext{
    
    static let storyboardName = Constants.Storyboard.PhotoEditor
    
    weak var delegate: PhotoEditorDelegate?

    private var model: PhotoEditorModel!
    
    private var router: protocol<FeedPresenter, AlertManagerDelegate>!
    private weak var locator: ServiceLocator!
    private var imageController: ImageViewController?
    private var stickersPickerController: StickersPickerViewController? {
        didSet {
            stickersPickerController?.delegate = self
        }
    }
    
    @IBOutlet private weak var stickerPickerContainer: UIView!
    @IBOutlet private weak var imageContainer: UIView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigavionBar()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        AlertManager.sharedInstance.registerAlertListener(router)
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
            imageController?.setLocator(locator)
            delegate = imageController
            
        case Constants.PhotoEditor.StickersPickerSegue:
            stickersPickerController = segue.destinationViewController as? StickersPickerViewController
            stickersPickerController?.stickersPickerAdapter = StickersPickerAdapter()
            stickersPickerController?.setLocator(locator)
            
        default:
            super.prepareForSegue(segue, sender: sender)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        layoutImageContainer()
        layoutStickersPickerContainer()
        view.layoutIfNeeded()
    }
    
    func didChooseStickerFromPicket(sticker: UIImage) {
        delegate?.photoEditor(self, didChooseSticker: sticker)
    }
    
    // MARK: - Setup methods
    func setLocator(locator: ServiceLocator) {
        self.locator = locator
    }
    
    func setRouter(router: PhotoEditorRouter) {
        self.router = router
    }
    
    func setModel(model: PhotoEditorModel) {
        self.model = model
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
            action: #selector(performBackNavigation)
        )
        navigationItem.leftBarButtonItem = newBackButton
        
        let savingButton = UIBarButtonItem(
            image: UIImage(named: "save"),
            style: .Plain,
            target: self,
            action: #selector(saveImageToCameraRoll)
        )
        
        let allStickerssRemovingButton = UIBarButtonItem(
            image: UIImage(named: "remove"),
            style: .Plain,
            target: self,
            action: #selector(removeAllStickers)
        )
        allStickerssRemovingButton.imageInsets = UIEdgeInsetsMake(0, 0, 0, -30)

        navigationItem.rightBarButtonItems = [savingButton, allStickerssRemovingButton]
        navigationItem.title = "Edit"
    }
    
    private func layoutImageContainer() {
        var size = imageContainer.frame.size
        size.width = view.bounds.width
        size.height = size.width
        imageContainer.bounds.size = size
    }
    
    private func layoutStickersPickerContainer() {
        var size = stickerPickerContainer.frame.size
        size.width = view.bounds.width
        stickerPickerContainer.bounds.size = size
    }
    
    private dynamic func performBackNavigation() {
        let alertController = UIAlertController(
            title: "Results wasn't saved",
            message: "Do you want to save result to the photo library?",
            preferredStyle: .ActionSheet
        )
        
        let saveAction = UIAlertAction(
            title: saveActionTitle,
            style: .Default
            ) { [weak self] _ in
                guard let this = self else {
                    return
                }
                this.saveImageToCameraRoll()
                this.navigationController!.popViewControllerAnimated(true)
        }
        alertController.addAction(saveAction)
        
        let dontSaveAction = UIAlertAction(
            title: dontSaveActionTitle,
            style: .Default
            ) { [weak self] _ in
                self?.navigationController!.popViewControllerAnimated(true)
        }
        alertController.addAction(dontSaveAction)
        
        let cancelAction = UIAlertAction(
            title: cancelActionTitle,
            style: .Cancel,
            handler: nil)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    private dynamic func saveImageToCameraRoll() {
        guard let image = delegate?.imageForPhotoEditor(self, withStickers: true) else {
            ExceptionHandler.handle(Exception.CantApplyStickers)
            
            return
        }
        
        PHPhotoLibrary.requestAuthorization { status in
            dispatch_async(dispatch_get_main_queue()) {
                switch status {
                case .Authorized:
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    AlertManager.sharedInstance.showSimpleAlert("Image saved to library")
                    
                default:
                    AlertManager.sharedInstance.showSimpleAlert("No access to photo library")
                }
            }
        }
    }
    
    private func postToFeed() {
        do {
            guard let image = delegate?.imageForPhotoEditor(self, withStickers: true) else {
                throw Exception.CantApplyStickers
            }
            var pictureData = UIImageJPEGRepresentation(image, 1.0)
            var i = 1.0
            while pictureData?.length > Constants.FileSize.MaxUploadSizeBytes {
                i = i - 0.1
                pictureData = UIImageJPEGRepresentation(image, CGFloat(i))
            }
            guard let file = PFFile(name: "image", data: pictureData!) else {
                throw Exception.CantCreateParseFile
            }
            let postService: PostService = locator.getService()
            postService.savePost(file)
            navigationController!.popViewControllerAnimated(true)
        } catch let exception {
            ExceptionHandler.handle(exception as! Exception)
        }
    }
    
    private func suggestSaveToCameraRoll() {
        let alertController = UIAlertController(
            title: Exception.NoConnection.rawValue,
            message: suggestSaveToCameraRollMessage,
            preferredStyle: .ActionSheet
        )
        
        let saveAction = UIAlertAction(
            title: saveActionTitle,
            style: .Default
            ) { [weak self] _ in
                self?.saveImageToCameraRoll()
        }
        alertController.addAction(saveAction)
        
        let postAction = UIAlertAction(
            title: postActionTitle,
            style: .Default
            ) { [weak self] _ in
            self?.postToFeed()
        }
        alertController.addAction(postAction)
        
        let cancelAction = UIAlertAction(
            title: cancelActionTitle,
            style: .Cancel,
            handler: nil)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }

    private dynamic func removeAllStickers() {
        delegate?.removeAllStickers(self)
    }
    
}

// MARK: - IBActions
extension PhotoEditorViewController {
    
    @IBAction private func postEditedImage() {
        let reachabilityService: ReachabilityService = locator.getService()
        guard reachabilityService.isReachable() else {
            suggestSaveToCameraRoll()
            
            return
        }
        postToFeed()
    }
    
}
