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
    
    private var image: UIImage?
    private var userName: String?
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nickNameTextField: UITextField!
    @IBOutlet weak var saveChangesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImagesAndText()
        makeNavigation()
    }
    
    private func setupImagesAndText() {
        photoGenerator.completionImageReceived = { [weak self] selectedImage in
            self?.handlePhotoSelected(selectedImage)
        }
        avatarImageView.layer.cornerRadius = avatarImageView.frame.height / 2
        avatarImageView.layer.masksToBounds = true
        saveChangesButton.enabled = false
        nickNameTextField.text = User.currentUser()?.username
        userName = User.currentUser()?.username
        let imgFromPFFileRepresentator = ImageLoaderService()
        imgFromPFFileRepresentator.getImageForContentItem(User.currentUser()?.avatar) {
            [weak self](image, error) -> () in
            if let error = error {
                print(error)
            } else {
                self?.avatarImageView.image = image
                self?.image = image
            }
        }
        
    }
    
    private func makeNavigation() {
        navigationItem.title = "Edit profile"
        let rightButton = UIBarButtonItem(
            title: "LogOut",
            style: UIBarButtonItemStyle.Plain,
            target: self,
            action: Selector("logout:")
        )
        navigationItem.rightBarButtonItem = rightButton
    }
    
    @objc func logout(sender: UIBarButtonItem) {
        AuthService().logOut()
        AuthService().anonymousLogIn(completion: { [weak self] object in
            Router.sharedRouter().showHome(animated: true)
            }, failure: { error in
                if let error = error {
                    handleError(error)
                }
        })
    }
    
    private func handlePhotoSelected(image: UIImage) {
        setSelectedPhoto(image)
        saveChangesButton.enabled = true
    }
    
    func setSelectedPhoto(image: UIImage) {
        avatarImageView.image = image
        self.image = image
    }
    
    @IBAction func avatarTapAction(sender: AnyObject) {
        photoGenerator.showInView(self)
    }
    
    @IBAction func saveChangesAction(sender: AnyObject) {
        ValidationService.valdateUserName(userName!) {
            [weak self] completion -> () in
            if completion {
                if let image = self?.image, let file = PFFile(name:
                    Constants.UserKey.Avatar,
                    data: UIImageJPEGRepresentation (image, 1)!) {
                        SaverService.uploadUserChanges(
                            User.currentUser()!,
                            avatar: file,
                            nickname: self?.userName
                        )
                        self?.navigationController?.popToRootViewControllerAnimated(true)
                }
            }
        }
    }
    
    //MARK: - TextFiel delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    @IBAction private func searchTextFieldValueChanged(sender: UITextField) {
        let afterStr = sender.text
        if userName != afterStr {
            userName = afterStr
            saveChangesButton.enabled = true
        }
    }
}
