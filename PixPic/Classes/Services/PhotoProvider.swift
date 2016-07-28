//
//  PhotoProvider.swift
//  UserProfile
//
//  Created by Admin on 10/30/15.
//  Copyright © 2015 yalantis. All rights reserved.
//

import UIKit
import AVFoundation

private let takePhotoOption = NSLocalizedString("take_photo", comment: "")
private let selectFromLibraryOption = NSLocalizedString("photo_from_library", comment: "")
private let importFromFabookOption = NSLocalizedString("import_from_facebook", comment: "")
private let cancelOption = NSLocalizedString("cancel", comment: "")

private let cameraAbsenceTitle = NSLocalizedString("no_camera", comment: "")
private let cameraAbsenceMessage = NSLocalizedString("Sorry, this device has no camera", comment: "")
private let okActionTitle = NSLocalizedString("OK", comment: "")

private let importantTitle = NSLocalizedString("IMPORTANT", comment: "")
private let askForCameraAccessMessage = NSLocalizedString("camera_access_required", comment: "")
private let allowCameraActionTitle = NSLocalizedString("allow_camera", comment: "")
private let cancelActionTitle = NSLocalizedString("cancel", comment: "")
private let allowCameraMessage = NSLocalizedString("allow_camera_access", comment: "")
private let dismissActionTitle = NSLocalizedString("dismiss", comment: "")

private let maxAllowedImageScale = 10

private let facebookFlow = "FacebookActivity"
private let facebookAlbumsListViewControllerID = "CSFFacebookAlbumsListTableViewController"

class PhotoProvider: NSObject, UINavigationControllerDelegate {
    
    private var controller: UIViewController!
    private lazy var imagePickerController = UIImagePickerController()
    var didSelectPhoto: (UIImage -> Void)?
    
    func presentPhotoOptionsDialog(in viewController: UIViewController) {
        self.controller = viewController
        imagePickerController.editing = false
        imagePickerController.delegate = self
        let actionSheetViewController = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .ActionSheet
        )
        let takePhotoAction = UIAlertAction.appAlertAction(
            title: takePhotoOption,
            style: .Default
        ) { _ in
            self.takePhoto()
            PushNotificationQueue.handleNotificationQueue()
        }
        let selectFromLibraryAction = UIAlertAction.appAlertAction(
            title: selectFromLibraryOption,
            style: .Default
        ) { _ in
            self.selectFromLibrary()
            PushNotificationQueue.handleNotificationQueue()
        }
        let importFromFacebookAction = UIAlertAction.appAlertAction(
            title: importFromFabookOption,
            style: .Default
        ) { _ in
            self.presentFacebookAlbumsList()
            PushNotificationQueue.handleNotificationQueue()
        }
        let cancelAction = UIAlertAction.appAlertAction(
            title: cancelOption,
            style: .Cancel
        ) { _ in
            PushNotificationQueue.handleNotificationQueue()
        }
        actionSheetViewController.addAction(takePhotoAction)
        actionSheetViewController.addAction(selectFromLibraryAction)
        actionSheetViewController.addAction(importFromFacebookAction)
        actionSheetViewController.addAction(cancelAction)
        controller.presentViewController(actionSheetViewController, animated: true, completion: nil)
    }
    
    // MARK: - Private methods
    private func takePhoto() {
        let cameraExists = UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil
            || UIImagePickerController.availableCaptureModesForCameraDevice(.Front) != nil
        if cameraExists {
            imagePickerController.sourceType = .Camera
            checkCameraAccessibility()
        } else {
            handleCameraAbsence()
        }
    }
    
    private func callCamera() {
        imagePickerController.cameraCaptureMode = .Photo
        imagePickerController.modalPresentationStyle = .FullScreen
        controller.presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    private func handleCameraAbsence() {
        let alertViewController = UIAlertController(
            title: cameraAbsenceTitle,
            message: cameraAbsenceMessage,
            preferredStyle: .Alert
        )
        let okAction = UIAlertAction.appAlertAction(
            title: okActionTitle,
            style:.Default,
            handler: nil
        )
        alertViewController.addAction(okAction)
        controller.presentViewController(alertViewController, animated: true, completion: nil)
    }
    
    private func selectFromLibrary() {
        imagePickerController.sourceType = .PhotoLibrary
        controller.presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    private func presentFacebookAlbumsList() {
        let board = UIStoryboard(name: facebookFlow, bundle: nil)
        let facebookViewController = board.instantiateViewControllerWithIdentifier(facebookAlbumsListViewControllerID) as! CSFFacebookAlbumsListViewController
        facebookViewController.successfulCropWithImageView = { [weak self] imageView in
            if let image = imageView?.image {
                self!.didSelectPhoto?(image)
            }
        }
        
        facebookViewController.fbAlbumsNeedsToDissmiss = { [weak self] in
            self?.controller.navigationController?.popToRootViewControllerAnimated(true)
        }
        controller.navigationController?.pushViewController(facebookViewController, animated: true)
    }
    
    private func checkCameraAccessibility() {
        let authorizationStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        switch authorizationStatus {
        case .Authorized:
            callCamera()
            
        case .Denied:
            askForCameraAccessViaSettings()
            
        default:
            presentCameraAccessDialog()
        }
    }
    
    private func askForCameraAccessViaSettings() {
        let alert = UIAlertController(
            title: importantTitle,
            message: askForCameraAccessMessage,
            preferredStyle: UIAlertControllerStyle.Alert
        )
        let cancelAction = UIAlertAction.appAlertAction(
            title: cancelActionTitle,
            style: .Default,
            handler: nil
        )
        let allowCameraAction = UIAlertAction.appAlertAction(
            title: allowCameraActionTitle,
            style: .Cancel
        ) { _ in
            UIApplication.redirectToAppSettings()
        }
        alert.addAction(cancelAction)
        alert.addAction(allowCameraAction)
        controller.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func presentCameraAccessDialog() {
        if AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo).count > 0 {
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo) { [weak self] granted in
                dispatch_async(dispatch_get_main_queue()) {
                    self?.checkCameraAccessibility()
                }
            }
        }
    }
    
}

extension PhotoProvider: UIImagePickerControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            presentCropperFor(image)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func presentCropperFor(image: UIImage) {
        let squareSideSize = imagePickerController.view.bounds.size.width
        let cropSquareOriginY = (imagePickerController.view.bounds.size.height - squareSideSize) / 2
        let cropSquare = CGRectMake(0, cropSquareOriginY, squareSideSize, squareSideSize)
        let imageCropperViewController = VPImageCropperViewController(image: image, cropFrame: cropSquare, limitScaleRatio: maxAllowedImageScale)
        imageCropperViewController.delegate = self
        imagePickerController.pushViewController(imageCropperViewController, animated: true)
    }
    
}
extension PhotoProvider: VPImageCropperDelegate {
    
    func imageCropper(cropperViewController: VPImageCropperViewController!, didFinished editedImage: UIImage!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        didSelectPhoto?(editedImage)
    }
    
    func imageCropperDidCancel(cropperViewController: VPImageCropperViewController!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
