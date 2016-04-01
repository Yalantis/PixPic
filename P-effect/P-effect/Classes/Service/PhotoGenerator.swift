//
//  PhotoGenerator.swift
//  UserProfile
//
//  Created by Admin on 10/30/15.
//  Copyright © 2015 yalantis. All rights reserved.
//

import UIKit
import AVFoundation

enum ListOfOptions: String {
    case takePhoto = "Take photo"
    case selectFromLibrary = "Choose photo from library"
    case cancel = "Cancel"
}

enum HandleNoCamera: String {
    case title = "No Camera"
    case message = "Sorry, this device has no camera"
    case okActionTitle = "OK"
}

enum CameraAccess: String {
    case importantTitle = "IMPORTANT"
    case askForCameraAccessMessage = "Camera access required"
    case allowCameraActionTitle = "Allow Camera"
    case cancelActionTitle = "Cancel"
    
    case allowCameraMessage = "Please allow camera access"
    case dismissActionTitle = "Dismiss"
}

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
            title: ListOfOptions.takePhoto.rawValue,
            style: .Default
            ) { _ in
                self.takePhoto()
                PushNotificationQueue.handleNotificationQueue()
        }
        let selectFromLibraryAction = UIAlertAction(
            title: ListOfOptions.selectFromLibrary.rawValue,
            style: .Default
            ) { _ in
                self.selectFromLibrary()
                PushNotificationQueue.handleNotificationQueue()
        }
        let cancelAction = UIAlertAction(
            title: ListOfOptions.cancel.rawValue,
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
            checkCamera()
        } else {
            handleNoCamera()
        }
    }
    
    private func callCamera() {
        imagePickerController.cameraCaptureMode = .Photo
        imagePickerController.modalPresentationStyle = .FullScreen
        imagePickerController.allowsEditing = true
        controller.presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    private func handleNoCamera() {
        let alertViewController = UIAlertController(
            title: HandleNoCamera.title.rawValue,
            message: HandleNoCamera.message.rawValue,
            preferredStyle: .Alert
        )
        let okAction = UIAlertAction(
            title: HandleNoCamera.okActionTitle.rawValue,
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
            title: CameraAccess.importantTitle.rawValue,
            message: CameraAccess.askForCameraAccessMessage.rawValue,
            preferredStyle: UIAlertControllerStyle.Alert
        )
        alert.addAction(UIAlertAction(
            title: CameraAccess.cancelActionTitle.rawValue,
            style: .Default,
            handler: nil)
        )
        alert.addAction(UIAlertAction(
            title: CameraAccess.allowCameraActionTitle.rawValue,
            style: .Cancel
            ) { _ in
                UIApplication.redirectToAppSettings()
        })
        controller.presentViewController(alert, animated: true, completion: nil)
    }
    
    private func presentCameraAccessDialog() {
        let alert = UIAlertController(
            title: CameraAccess.importantTitle.rawValue,
            message: CameraAccess.allowCameraMessage.rawValue,
            preferredStyle: UIAlertControllerStyle.Alert
        )
        alert.addAction(UIAlertAction(
            title: CameraAccess.dismissActionTitle.rawValue,
            style: .Cancel
            ) { _ in
                if AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo).count > 0 {
                    AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo) { [weak self] granted in
                        dispatch_async(dispatch_get_main_queue()) {
                            self?.checkCamera()
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
