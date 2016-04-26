//
//  PhotoProvider.swift
//  UserProfile
//
//  Created by Admin on 10/30/15.
//  Copyright © 2015 yalantis. All rights reserved.
//

import UIKit
import AVFoundation

private let takePhotoOption = "Take photo"
private let selectFromLibraryOption = "Choose photo from library"
private let cancelOption = "Cancel"

private let cameraAbsenceTitle = "No Camera"
private let cameraAbsenceMessage = "Sorry, this device has no camera"
private let okActionTitle = "OK"

private let importantTitle = "IMPORTANT"
private let askForCameraAccessMessage = "Camera access required"
private let allowCameraActionTitle = "Allow Camera"
private let cancelActionTitle = "Cancel"
private let allowCameraMessage = "Please allow camera access"
private let dismissActionTitle = "Dismiss"

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
        let takePhotoAction = UIAlertAction(
            title: takePhotoOption,
            style: .Default
            ) { _ in
                self.takePhoto()
                PushNotificationQueue.handleNotificationQueue()
        }
        let selectFromLibraryAction = UIAlertAction(
            title: selectFromLibraryOption,
            style: .Default
            ) { _ in
                self.selectFromLibrary()
                PushNotificationQueue.handleNotificationQueue()
        }
        let cancelAction = UIAlertAction(
            title: cancelOption,
            style: .Cancel
            ) { _ in
                PushNotificationQueue.handleNotificationQueue()
        }
        actionSheetViewController.addAction(selectFromLibraryAction)
        actionSheetViewController.addAction(takePhotoAction)
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
        imagePickerController.allowsEditing = true
        controller.presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    private func handleCameraAbsence() {
        let alertViewController = UIAlertController(
            title: cameraAbsenceTitle,
            message: cameraAbsenceMessage,
            preferredStyle: .Alert
        )
        let okAction = UIAlertAction(
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
        imagePickerController.allowsEditing = true
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
        let cancelAction = UIAlertAction(
            title: cancelActionTitle,
            style: .Default,
            handler: nil
        )
        let allowCameraAction = UIAlertAction(
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
        let alert = UIAlertController(
            title: importantTitle,
            message: allowCameraActionTitle,
            preferredStyle: UIAlertControllerStyle.Alert
        )
        let dismissAction = UIAlertAction(
            title: dismissActionTitle,
            style: .Cancel
            ) { _ in
                if AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo).count > 0 {
                    AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo) { [weak self] granted in
                        dispatch_async(dispatch_get_main_queue()) {
                            self?.checkCameraAccessibility()
                        }
                    }
                }
        }
        alert.addAction(dismissAction)
        controller.presentViewController(alert, animated: true, completion: nil)
    }
    
}

extension PhotoProvider: UIImagePickerControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: AnyObject]) {
        if let selectedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            controller.dismissViewControllerAnimated(true, completion: nil)
            didSelectPhoto?(selectedImage)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
