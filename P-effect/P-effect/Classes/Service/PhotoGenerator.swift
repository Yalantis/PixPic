//
//  PhotoGenerator.swift
//  UserProfile
//
//  Created by Admin on 10/30/15.
//  Copyright © 2015 yalantis. All rights reserved.
//

import UIKit
import AVFoundation

private let takePhotoActionTitle =          "Take photo"
private let selectFromLibraryActionTitle =  "Choose photo from library"
private let cancelActionTitle =             "Cancel"
private let noCameraTitle =                 "No Camera"
private let noCameraMessage =               "Sorry, this device has no camera"
private let okActionTitle =                 "OK"
private let importantTitle =                "IMPORTANT"
private let allowCameraActionTitle =        "Allow Camera"
private let allowCameraMessage =            "Please allow camera access"
private let askForCameraAccessMessage =     "Camera access required"
private let dismissActionTitle =            "Dismiss"

class PhotoGenerator: NSObject, UINavigationControllerDelegate {
    
    private var controller: UIViewController!
    private lazy var imagePickerController = UIImagePickerController()
    var completionImageReceived:(UIImage -> Void)?
    
    func showInView(controller: UIViewController) {
        self.controller = controller
        imagePickerController.editing = false
        imagePickerController.delegate = self
        let actionSheetVC = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .ActionSheet
        )
        let takePhotoAction = UIAlertAction(
            title: takePhotoActionTitle,
            style: .Default
            ) { _ in
                self.takePhoto()
                PushNotificationQueue.handleNotificationQueue()
        }
        let selectFromLibraryAction = UIAlertAction(
            title: selectFromLibraryActionTitle,
            style: .Default
            ) { _ in
                self.selectFromLibrary()
                PushNotificationQueue.handleNotificationQueue()
        }
        let cancelAction = UIAlertAction(
            title: cancelActionTitle,
            style: .Cancel
            ) { _ in
                PushNotificationQueue.handleNotificationQueue()
        }
        actionSheetVC.addAction(selectFromLibraryAction)
        actionSheetVC.addAction(takePhotoAction)
        actionSheetVC.addAction(cancelAction)
        controller.presentViewController(actionSheetVC, animated: true, completion: nil)
    }
    
    // MARK: - Private methods
    private func takePhoto() {
        let cameraExist = UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil
            || UIImagePickerController.availableCaptureModesForCameraDevice(.Front) != nil
        if cameraExist {
            imagePickerController.sourceType = .Camera
            checkCamera()
        } else {
            noCamera()
        }
    }
    
    private func callCamera() {
        imagePickerController.cameraCaptureMode = .Photo
        imagePickerController.modalPresentationStyle = .FullScreen
        imagePickerController.allowsEditing = true
        controller.presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    private func noCamera() {
        let alertVC = UIAlertController(
            title: noCameraTitle,
            message: noCameraMessage,
            preferredStyle: .Alert
        )
        let okAction = UIAlertAction(
            title: okActionTitle,
            style:.Default,
            handler: nil
        )
        alertVC.addAction(okAction)
        controller.presentViewController(alertVC, animated: true, completion: nil)
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
            title: importantTitle,
            message: allowCameraMessage,
            preferredStyle: UIAlertControllerStyle.Alert
        )
        alert.addAction(UIAlertAction(
            title: cancelActionTitle,
            style: .Default,
            handler: nil)
        )
        alert.addAction(UIAlertAction(
            title: askForCameraAccessMessage,
            style: .Cancel
            ) { _ in
                UIApplication.redirectToAppSettings()
        })
        controller.presentViewController(alert, animated: true, completion: nil)
    }
    
    func presentCameraAccessDialog() {
        let alert = UIAlertController(
            title: importantTitle,
            message: allowCameraMessage,
            preferredStyle: UIAlertControllerStyle.Alert
        )
        alert.addAction(UIAlertAction(
            title: dismissActionTitle,
            style: .Cancel
            ) { _ in
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
        let selectedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        controller.dismissViewControllerAnimated(true, completion: nil)
        completionImageReceived?(selectedImage)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
