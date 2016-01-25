//
//  EditProfileViewController.swift
//  P-effect
//
//  Created by Jack Lapin on 20.01.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

private let logoutMessage = "This will logout you. And you will not be able to share you photos..("

class EditProfileViewController: UIViewController, UITextFieldDelegate, MBProgressHUDDelegate {
    
    private lazy var photoGenerator = PhotoGenerator()
    private lazy var hud = MBProgressHUD()
    
    private var image: UIImage?
    private var userName: String?
    
    var kbHeight: CGFloat?
    private var kbHidden: Bool = true
    
    
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var nickNameTextField: UITextField!
    @IBOutlet private weak var saveChangesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeNavigation()
        view.layoutIfNeeded()
        setupImagesAndText()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name:UIKeyboardWillHideNotification, object: nil);
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2.0
    }
    
    private func setupImagesAndText() {
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        photoGenerator.completionImageReceived = { [weak self] selectedImage in
            self?.handlePhotoSelected(selectedImage)
        }
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
            action: Selector("logoutAction:")
        )
        navigationItem.rightBarButtonItem = rightButton
    }
    
    func logoutAction(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: nil,
            message: logoutMessage,
            preferredStyle: .ActionSheet
        )
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) {
            (action) in
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        let OKAction = UIAlertAction(title: "Logout me!", style: .Default) {
            [weak self] (action) in
            self?.logout()
        }
        alertController.addAction(OKAction)
        presentViewController(alertController, animated: true) {}
    }
    
    func logout() {
        AuthService().logOut()
        AuthService().anonymousLogIn(
            completion: {
                object in
                Router.sharedRouter().showHome(animated: true)
            }, failure: { error in
                if let error = error {
                    handleError(error)
                }
            }
        )
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize =  (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                kbHeight = keyboardSize.height
                self.animateTextField(true)
                kbHidden = false
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        animateTextField(false)
        kbHidden = true
    }
    
    func animateTextField(up: Bool) {
        if let kbheight = kbHeight {
            let movement = (up ? -kbheight : kbheight)
            UIView.animateWithDuration(
                0.3,
                animations: {
                    [weak self] () -> Void in
                    if let offset = (self?.view.frame) {
                        self?.view.frame = CGRectOffset(offset, 0, movement)
                    }
                }
            )
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        kbHidden = true
        
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
    
    @objc @IBAction func saveChangesAction(sender: AnyObject) {
        if let image = image {
            let pictureData = UIImageJPEGRepresentation(image, 1)
            if let file = PFFile(name: Constants.UserKey.Avatar, data: pictureData!) {
                view.makeToastActivity(CSToastPositionCenter)
                view.userInteractionEnabled = false
                SaverService.uploadUserChanges(
                    User.currentUser()!,
                    avatar: file,
                    nickname: userName,
                    completion: {
                        [weak self] (success, error) in
                        if let error = error {
                            print(error)
                            self?.view.hideToastActivity()
                            self?.view.userInteractionEnabled = true
                        } else {
                            self?.view.hideToastActivity()
                            self?.navigationController?.popToRootViewControllerAnimated(true)
                        }
                    }
                )
            }
        }
    }
    
    
    //MARK: - TextField delegate
    
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
