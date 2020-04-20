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

private let importantTitle = NSLocalizedString("no_camera_access", comment: "")
private let askForCameraAccessMessage = NSLocalizedString("camera_access_required", comment: "")
private let allowCameraActionTitle = NSLocalizedString("allow_access", comment: "")
private let cancelActionTitle = NSLocalizedString("cancel", comment: "")
private let allowCameraMessage = NSLocalizedString("allow_camera_access", comment: "")
private let dismissActionTitle = NSLocalizedString("dismiss", comment: "")

private let maxAllowedImageScale = 10

private let facebookFlow = "FacebookActivity"
private let facebookAlbumsListViewControllerID = "CSFFacebookAlbumsListTableViewController"

class PhotoProvider: NSObject, UINavigationControllerDelegate {

    fileprivate var controller: UIViewController!
    fileprivate lazy var imagePickerController = UIImagePickerController()
    var didSelectPhoto: ((UIImage) -> Void)?

    func presentPhotoOptionsDialog(in viewController: UIViewController) {
        self.controller = viewController
        imagePickerController.isEditing = false
        imagePickerController.delegate = self
        let actionSheetViewController = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
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
        controller.present(actionSheetViewController, animated: true, completion: nil)
    }

    // MARK: - Private methods
    fileprivate func takePhoto() {
        let cameraExists = UIImagePickerController.availableCaptureModes(for: .rear) != nil
            || UIImagePickerController.availableCaptureModes(for: .front) != nil
        if cameraExists {
            imagePickerController.sourceType = .camera
            checkCameraAccessibility()
        } else {
            handleCameraAbsence()
        }
    }

    fileprivate func callCamera() {
        imagePickerController.cameraCaptureMode = .photo
        imagePickerController.modalPresentationStyle = .fullScreen
        controller.present(imagePickerController, animated: true, completion: nil)
    }

    fileprivate func handleCameraAbsence() {
        let alertViewController = UIAlertController(
            title: cameraAbsenceTitle,
            message: cameraAbsenceMessage,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction.appAlertAction(
            title: okActionTitle,
            style:.Default,
            handler: nil
        )
        alertViewController.addAction(okAction)
        controller.present(alertViewController, animated: true, completion: nil)
    }

    fileprivate func selectFromLibrary() {
        imagePickerController.sourceType = .photoLibrary
        controller.present(imagePickerController, animated: true, completion: nil)
    }

    fileprivate func presentFacebookAlbumsList() {
        let board = UIStoryboard(name: facebookFlow, bundle: nil)
        let facebookViewController = board.instantiateViewControllerWithIdentifier(facebookAlbumsListViewControllerID)
            as! CSFFacebookAlbumsListViewController
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

    fileprivate func checkCameraAccessibility() {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch authorizationStatus {
        case .authorized:
            callCamera()

        case .denied:
            askForCameraAccessViaSettings()

        default:
            presentCameraAccessDialog()
        }
    }

    fileprivate func askForCameraAccessViaSettings() {
        let alert = UIAlertController(
            title: importantTitle,
            message: askForCameraAccessMessage,
            preferredStyle: UIAlertControllerStyle.alert
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
        controller.present(alert, animated: true, completion: nil)
    }

    fileprivate func presentCameraAccessDialog() {
        if AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo).count > 0 {
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.checkCameraAccessibility()
                }
            }
        }
    }

}

extension PhotoProvider: UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            presentCropperFor(image)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        controller.dismiss(animated: true, completion: nil)
    }

    fileprivate func presentCropperFor(_ image: UIImage) {
        let squareSideSize = imagePickerController.view.bounds.size.width
        let cropSquareOriginY = (imagePickerController.view.bounds.size.height - squareSideSize) / 2
        let cropSquare = CGRect(x: 0, y: cropSquareOriginY, width: squareSideSize, height: squareSideSize)
        let imageCropperViewController = VPImageCropperViewController(image: image,
                                                                      cropFrame: cropSquare,
                                                                      limitScaleRatio: maxAllowedImageScale)
        imageCropperViewController.delegate = self
        imagePickerController.pushViewController(imageCropperViewController, animated: true)
    }

}
extension PhotoProvider: VPImageCropperDelegate {

    func imageCropper(_ cropperViewController: VPImageCropperViewController!, didFinished editedImage: UIImage!) {
        controller.dismiss(animated: true, completion: nil)
        didSelectPhoto?(editedImage)
    }

    func imageCropperDidCancel(_ cropperViewController: VPImageCropperViewController!) {
        controller.dismiss(animated: true, completion: nil)
    }

}
