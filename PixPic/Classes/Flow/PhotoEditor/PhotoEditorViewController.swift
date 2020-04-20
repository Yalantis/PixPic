//
//  PhotoEditorViewController.swift
//  PixPic
//
//  Created by Illya on 1/25/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import Photos
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


typealias PhotoEditorRouterInterface = AuthorizationRouterInterface

protocol PhotoEditorDelegate: class {

    func photoEditor(_ photoEditor: PhotoEditorViewController, didChooseSticker: UIImage)
    func imageForPhotoEditor(_ photoEditor: PhotoEditorViewController, withStickers: Bool) -> UIImage
    func removeAllStickers(_ photoEditor: PhotoEditorViewController)

}

private let cancelActionTitle = NSLocalizedString("cancel", comment: "")
private let postActionTitle = NSLocalizedString("post_with_delay", comment: "")
private let saveActionTitle = NSLocalizedString("save", comment: "")
private let dontSaveActionTitle = NSLocalizedString("don't_save", comment: "")

private let suggestSaveToCameraRollMessage = NSLocalizedString("save_result_after_internet_appears", comment: "")

final class PhotoEditorViewController: UIViewController, StoryboardInitiable, NavigationControllerAppearanceContext {

    static let storyboardName = Constants.Storyboard.photoEditor

    weak var delegate: PhotoEditorDelegate?

    fileprivate var model: PhotoEditorModel!

    fileprivate var router: PhotoEditorRouterInterface!
    fileprivate weak var locator: ServiceLocator!
    fileprivate var imageController: ImageViewController?
    fileprivate var stickersPickerController: StickersPickerViewController? {
        didSet {
            stickersPickerController?.delegate = self
        }
    }

    @IBOutlet fileprivate weak var stickerPickerContainer: UIView!
    @IBOutlet fileprivate weak var imageContainer: UIView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigavionBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        AlertManager.sharedInstance.setAlertDelegate(router)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        PushNotificationQueue.handleNotificationQueue()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case Constants.PhotoEditor.imageViewControllerSegue:
            imageController = segue.destination as? ImageViewController
            imageController?.model = ImageViewModel(image: model.originalImage)
            imageController?.setLocator(locator)
            delegate = imageController

        case Constants.PhotoEditor.stickersPickerSegue:
            stickersPickerController = segue.destination as? StickersPickerViewController
            stickersPickerController?.setLocator(locator)

        default:
            super.prepare(for: segue, sender: sender)
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        layoutImageContainer()
        layoutStickersPickerContainer()
        view.layoutIfNeeded()
    }

    func didChooseStickerFromPicket(_ sticker: UIImage) {
        delegate?.photoEditor(self, didChooseSticker: sticker)
    }

    // MARK: - Setup methods
    func setLocator(_ locator: ServiceLocator) {
        self.locator = locator
    }

    func setRouter(_ router: PhotoEditorRouterInterface) {
        self.router = router
    }

    func setModel(_ model: PhotoEditorModel) {
        self.model = model
    }

}

// MARK: - Private methods
extension PhotoEditorViewController {

    fileprivate func setupNavigavionBar() {
        navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(
            image: UIImage.appBackButton,
            style: .plain,
            target: self,
            action: #selector(performBackNavigation)
        )
        navigationItem.leftBarButtonItem = newBackButton

        let savingButton = UIBarButtonItem(
            image: UIImage(named: "ic_save"),
            style: .plain,
            target: self,
            action: #selector(saveImageToCameraRoll)
        )

        let removeAllStickersButton = UIBarButtonItem(
            image: UIImage(named: "ic_remove"),
            style: .plain,
            target: self,
            action: #selector(removeAllStickers)
        )
        removeAllStickersButton.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -30)

        navigationItem.rightBarButtonItems = [savingButton, removeAllStickersButton]
        navigationItem.title = "Edit"
    }

    fileprivate func layoutImageContainer() {
        var size = imageContainer.frame.size
        size.width = view.bounds.width
        size.height = size.width
        imageContainer.bounds.size = size
    }

    fileprivate func layoutStickersPickerContainer() {
        var size = stickerPickerContainer.frame.size
        size.width = view.bounds.width
        stickerPickerContainer.bounds.size = size
    }

    @objc fileprivate func performBackNavigation() {
        let alertController = UIAlertController(
            title: "Result wasn't saved",
            message: "Do you want to save result to the photo library?",
            preferredStyle: .actionSheet
        )

        let saveAction = UIAlertAction.appAlertAction(
            title: saveActionTitle,
            style: .Default, color: UIColor.redColor()
        ) { [weak self] _ in
            guard let this = self else {
                return
            }
            this.saveImageToCameraRoll()
            this.navigationController!.popViewControllerAnimated(true)
        }

        alertController.addAction(saveAction)

        let dontSaveAction = UIAlertAction.appAlertAction(
            title: dontSaveActionTitle,
            style: .Default
        ) { [weak self] _ in
            self?.navigationController!.popViewControllerAnimated(true)
        }
        alertController.addAction(dontSaveAction)

        let cancelAction = UIAlertAction.appAlertAction(
            title: cancelActionTitle,
            style: .Cancel,
            handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    @objc fileprivate func saveImageToCameraRoll() {
        guard let image = delegate?.imageForPhotoEditor(self, withStickers: true) else {
            ExceptionHandler.handle(Exception.CantApplyStickers)

            return
        }

        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    AlertManager.sharedInstance.showSimpleAlert("Image was saved to the photo library")

                default:
                    AlertManager.sharedInstance.showSimpleAlert("No access to the photo library")
                }
            }
        }
    }

    fileprivate func postToFeed() {
        do {
            guard let image = delegate?.imageForPhotoEditor(self, withStickers: true) else {
                throw Exception.CantApplyStickers
            }
            var imageData = UIImageJPEGRepresentation(image, 1.0)
            var i = 1.0
            while imageData?.count > Constants.FileSize.maxUploadSizeBytes {
                i = i - 0.1
                imageData = UIImageJPEGRepresentation(image, CGFloat(i))
            }
            guard let file = PFFile(name: "image", data: imageData!) else {
                throw Exception.CantCreateParseFile
            }
            let postService: PostService = locator.getService()
            postService.savePost(file)
            navigationController!.popToRootViewController(animated: true)
        } catch let exception {
            ExceptionHandler.handle(exception as! Exception)
        }
    }

    fileprivate func suggestSaveToCameraRoll() {
        let alertController = UIAlertController(
            title: Exception.NoConnection.rawValue,
            message: suggestSaveToCameraRollMessage,
            preferredStyle: .actionSheet
        )

        let saveAction = UIAlertAction.appAlertAction(
            title: saveActionTitle,
            style: .Default
        ) { [weak self] _ in
            self?.saveImageToCameraRoll()
        }
        alertController.addAction(saveAction)

        let postAction = UIAlertAction.appAlertAction(
            title: postActionTitle,
            style: .Default
        ) { [weak self] _ in
            self?.postToFeed()
        }
        alertController.addAction(postAction)

        let cancelAction = UIAlertAction.appAlertAction(
            title: cancelActionTitle,
            style: .Cancel,
            handler: nil)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    @objc fileprivate func removeAllStickers() {
        delegate?.removeAllStickers(self)
    }

}

// MARK: - IBActions
extension PhotoEditorViewController {

    @IBAction fileprivate func postEditedImage() {
        guard ReachabilityHelper.isReachable() else {
            suggestSaveToCameraRoll()

            return
        }
        postToFeed()
    }

}
