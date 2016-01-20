//
//  EditProfileViewController.swift
//  P-effect
//
//  Created by Jack Lapin on 20.01.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController, UITextFieldDelegate {
    
    private lazy var photoGenerator = PhotoGenerator()
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nickNameTextField: UITextField!
    
    @IBOutlet weak var saveChangesButton: UIButton!
    @IBAction func avatarTapAction(sender: AnyObject) {
        photoGenerator.completionImageReceived = { [weak self] selectedImage in
            self?.handlePhotoSelected(selectedImage)
        }
        photoGenerator.showInView(self)
    }
    
    @IBAction func saveChangesAction(sender: AnyObject) {
        if let image = avatarImageView.image {
            let pictureData = UIImageJPEGRepresentation(image, 1)
            if let file = PFFile(name: "image", data: pictureData!) {
                let saver = SaverService()
                saver.saveAndUploadUserData(User.currentUser()!, avatar: file, nickname: nickNameTextField.text)
                self.navigationController?.popToRootViewControllerAnimated(true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImagesAndText()
        navigationController?.navigationBarHidden = false
    }
    
    private func setupImagesAndText() {
        saveChangesButton.enabled = false
        nickNameTextField.text = User.currentUser()?.username
        let imgFromPFFileRepresentator = ImageLoaderService()
        imgFromPFFileRepresentator.getImageForContentItem(User.currentUser()?.avatar) {
            [weak self](image, error) -> () in
            if let error = error {
                print(error)
            } else {
                self?.avatarImageView.image = image
            }
        }
    }
    
    private func handlePhotoSelected(image: UIImage) {
        setSelectedPhoto(image)
        saveChangesButton.enabled = true
    }
    
    func setSelectedPhoto(image: UIImage) {
        avatarImageView.image = image
    }
    
    //MARK: - TextFiel delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
