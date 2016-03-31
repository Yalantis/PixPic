//
//  PhotoGenerator.swift
//  UserProfile
//
//  Created by Admin on 10/30/15.
//  Copyright © 2015 yalantis. All rights reserved.
//

import UIKit
import AVFoundation

private let takePhotoActionTitle = "Take photo"
private let selectFromLibraryActionTitle = "Choose photo from library"
private let cancelActionTitle = "Cancel"

class PhotoGenerator: NSObject, UINavigationControllerDelegate {
    
    private var controller: UIViewController!
    private lazy var imagePickerController = UIImagePickerController()
    var didSelectPhoto: (UIImage -> Void)?
    
    func showListOfOptions(inViewController controller: UIViewController) {
        self.controller = controller
        imagePickerController.editing = false
        imagePickerController.delegate = self
        let actionSheetViewController = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .ActionSheet
        )
        let takePhotoAction = UIAlertAction(
            title: takePhotoActionTitle,
            style: .Default,
            handler: { _ in
                self.takePhoto()
                PushNotificationQueue.handleNotificationQueue()
            }
        )
        let selectFromLibraryAction = UIAlertAction(
            title: selectFromLibraryActionTitle,
            style: .Default,
            handler: { _ in
                self.selectFromLibrary()
                PushNotificationQueue.handleNotificationQueue()
            }
        )
        let cancelAction = UIAlertAction(
            title: cancelActionTitle,
            style: .Cancel,
            handler: { _ in
                PushNotificationQueue.handleNotificationQueue()
            }
        )
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
            checkCamera()
        } else {
            showWarningAboutAbsenceCamera()
        }
    }
    
    private func callCamera() {
        imagePickerController.cameraCaptureMode = .Photo
        imagePickerController.modalPresentationStyle = .FullScreen
        imagePickerController.allowsEditing = true
        controller.presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    private func showWarningAboutAbsenceCamera() {
        let alertViewController = UIAlertController(
            title: "No Camera",
            message: "Sorry, this device has no camera",
            preferredStyle: .Alert
        )
        let okAction = UIAlertAction(
            title: "OK",
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
    
    private func checkCamera() {
        let authStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        switch authStatus {
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
            title: "IMPORTANT",
            message: "Camera access required",
            preferredStyle: UIAlertControllerStyle.Alert
        )
        alert.addAction(UIAlertAction(
            title: "Cancel",
            style: .Default,
            handler: nil)
        )
        alert.addAction(UIAlertAction(
            title: "Allow Camera",
            style: .Cancel,
            handler: { _ in
                UIApplication.redirectToAppSettings()
            }
            )
        )
        controller.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func presentCameraAccessDialog() {
        let alert = UIAlertController(
            title: "IMPORTANT",
            message: "Please allow camera access",
            preferredStyle: UIAlertControllerStyle.Alert
        )
        alert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel) { _ in
            if AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo).count > 0 {
                AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo) { granted in
                    dispatch_async(dispatch_get_main_queue()) {
                        self.checkCamera()
                    }
                }
            }
            }
        )
        controller.presentViewController(alert, animated: true, completion: nil)
    }
    
}

extension PhotoGenerator: UIImagePickerControllerDelegate {
    
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
