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
    case TakePhoto = "Take photo"
    case SelectFromLibrary = "Choose photo from library"
    case Cancel = "Cancel"
}

enum HandleNoCamera: String {
    case Title = "No Camera"
    case Message = "Sorry, this device has no camera"
    case OkActionTitle = "OK"
}

enum CameraAccess: String {
    case ImportantTitle = "IMPORTANT"
    case AskForCameraAccessMessage = "Camera access required"
    case AllowCameraActionTitle = "Allow Camera"
    case CancelActionTitle = "Cancel"
    
    case AllowCameraMessage = "Please allow camera access"
    case DismissActionTitle = "Dismiss"
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
            title: ListOfOptions.TakePhoto.rawValue,
            style: .Default
            ) { _ in
                self.takePhoto()
                PushNotificationQueue.handleNotificationQueue()
        }
        let selectFromLibraryAction = UIAlertAction(
            title: ListOfOptions.SelectFromLibrary.rawValue,
            style: .Default
            ) { _ in
                self.selectFromLibrary()
                PushNotificationQueue.handleNotificationQueue()
        }
        let cancelAction = UIAlertAction(
            title: ListOfOptions.Cancel.rawValue,
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
            title: HandleNoCamera.Title.rawValue,
            message: HandleNoCamera.Message.rawValue,
            preferredStyle: .Alert
        )
        let okAction = UIAlertAction(
            title: HandleNoCamera.OkActionTitle.rawValue,
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
            title: CameraAccess.ImportantTitle.rawValue,
            message: CameraAccess.AskForCameraAccessMessage.rawValue,
            preferredStyle: UIAlertControllerStyle.Alert
        )
        let cancelAction = UIAlertAction(
            title: CameraAccess.CancelActionTitle.rawValue,
            style: .Default,
            handler: nil
        )
        let allowCameraAction = UIAlertAction(
            title: CameraAccess.AllowCameraActionTitle.rawValue,
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
            title: CameraAccess.ImportantTitle.rawValue,
            message: CameraAccess.AllowCameraMessage.rawValue,
            preferredStyle: UIAlertControllerStyle.Alert
        )
        let dismissAction = UIAlertAction(
            title: CameraAccess.DismissActionTitle.rawValue,
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
        alert.addAction(dismissAction)
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
