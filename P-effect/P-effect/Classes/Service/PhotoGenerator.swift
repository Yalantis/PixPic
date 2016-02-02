//
//  PhotoGenerator.swift
//  UserProfile
//
//  Created by Admin on 10/30/15.
//  Copyright © 2015 yalantis. All rights reserved.
//

import UIKit

public class PhotoGenerator: NSObject, UINavigationControllerDelegate {
    
    private var controller: UIViewController!
    private lazy var imagePickerController = UIImagePickerController()
    var completionImageReceived:(UIImage -> Void)?
    
    public func showInView(controller: UIViewController) {
        self.controller = controller
        imagePickerController.editing = false
        imagePickerController.delegate = self
        let actionSheetVC = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let takePhotoAction = UIAlertAction(title: "Take photo", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.takePhoto()
            PushNotificationQueue.handleNotificationQueue()
        })
        let selectFromLibraryAction = UIAlertAction(title: "Choose photo from library", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.selectFromLibrary()
            PushNotificationQueue.handleNotificationQueue()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            PushNotificationQueue.handleNotificationQueue()
        })
        actionSheetVC.addAction(selectFromLibraryAction)
        actionSheetVC.addAction(takePhotoAction)
        actionSheetVC.addAction(cancelAction)
        controller.presentViewController(actionSheetVC, animated: true, completion: nil)
    }
    
    // MARK: - Private methods
    private func takePhoto() {
        let cameraExist: Bool = UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil
            || UIImagePickerController.availableCaptureModesForCameraDevice(.Front) != nil
        if cameraExist {
            imagePickerController.sourceType = .Camera
            imagePickerController.cameraCaptureMode = .Photo
            imagePickerController.modalPresentationStyle = .FullScreen
            imagePickerController.allowsEditing = true

            controller.presentViewController(imagePickerController, animated: true, completion: nil)
        }
        else {
           noCamera()
        }
    }
    
    private func noCamera() {
        let alertVC = UIAlertController(title: "No Camera", message: "Sorry, this device has no camera", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style:.Default, handler: nil)
        alertVC.addAction(okAction)
        controller.presentViewController(alertVC, animated: true, completion: nil)
    }
    
    private func selectFromLibrary() {
        imagePickerController.sourceType = .PhotoLibrary
        controller.presentViewController(imagePickerController, animated: true, completion: nil)
        imagePickerController.allowsEditing = true
    }
    
}

extension PhotoGenerator: UIImagePickerControllerDelegate {
    
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let selectedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        controller.dismissViewControllerAnimated(true, completion: nil)
        completionImageReceived?(selectedImage)
    }
    
    public func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}
