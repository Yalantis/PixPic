//
//  EditProfileViewController.swift
//  P-effect
//
//  Created by Jack Lapin on 20.01.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import Toast

private let logoutMessage = "This will logout you. And you will not be able to share your amazing photos..("
private let backWithChangesMessage = "If you go back now, your changes will be discarded"
private let logoutWithoutConnectionAttempt = "Internet connection is required to logout"


final class EditProfileViewController: UIViewController, Creatable {
    
    var router: EditProfileRouter!
    
    private lazy var photoGenerator = PhotoGenerator()
    
    private var image: UIImage?
    private var userName: String?
    private var originalUserName: String?
    
    private var kbHeight: CGFloat = 0.0
    private var kbHidden = true
    private var someChangesMade = false
    private var usernameChanged = false
    
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var nickNameTextField: UITextField!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var topConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeNavigation()
        view.layoutIfNeeded()
        configureImagesAndText()
        subscribeOnNotifications()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self);
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        AlertService.allowToDisplay = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        AlertService.allowToDisplay = true
        PushNotificationQueue.handleNotificationQueue()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2.0
    }
    
    private func subscribeOnNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "keyboardWillShow:",
            name: UIKeyboardWillShowNotification,
            object: nil
        )
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "keyboardWillHide:",
            name: UIKeyboardWillHideNotification,
            object: nil
        )
    }
    
    private func configureImagesAndText() {
        let tap = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        
        photoGenerator.completionImageReceived = { [weak self] selectedImage in
            self?.handlePhotoSelected(selectedImage)
        }
        avatarImageView.layer.masksToBounds = true
        navigationItem.rightBarButtonItem!.enabled = false
        nickNameTextField.text = User.currentUser()?.username
        userName = User.currentUser()?.username
        originalUserName = userName
        guard let avatar = User.currentUser()?.avatar else {
            return
        }
        ImageLoaderService.getImageForContentItem(avatar) {
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
            title: "Save",
            style: .Plain,
            target: self,
            action: "saveChangesAction"
        )
        navigationItem.rightBarButtonItem = rightButton
        
        let leftButton = UIBarButtonItem(
            image: UIImage.appBackButton(),
            style: .Plain,
            target: self,
            action: "handleBackButtonTap"
        )
        navigationItem.leftBarButtonItem = leftButton
    }
    
    dynamic private func handleBackButtonTap() {
        if someChangesMade {
            let alertController = UIAlertController(
                title: "Save changes",
                message: backWithChangesMessage, preferredStyle: .Alert
            )
            let NOAction = UIAlertAction(title: "Ok", style: .Cancel) {
                [weak self] action in
                PushNotificationQueue.handleNotificationQueue()
                alertController.dismissViewControllerAnimated(true, completion: nil)
                self?.navigationController!.popViewControllerAnimated(true)
            }
            alertController.addAction(NOAction)
            
            let YESAction = UIAlertAction(title: "Save", style: .Default) {
                [weak self] action in
                self?.saveChangesAction()
                PushNotificationQueue.handleNotificationQueue()
            }
            alertController.addAction(YESAction)
            
            self.presentViewController(alertController, animated: true) {}
        } else {
            navigationController!.popViewControllerAnimated(true)
        }
    }
    
    dynamic private func saveChangesAction() {
        navigationItem.rightBarButtonItem!.enabled = false
        if ReachabilityHelper.checkConnection(showAlert: false) {
            guard let userName = userName where originalUserName != userName else {
                saveChanges()
                return
            }
            ValidationService.validateUserName(userName) { [weak self] completion in
                if completion {
                    self?.saveChanges()
                }
            }
        } else {
            AlertService.simpleAlert("Internet connection is required to save changes in profile")
        }
    }
    
    private func logout() {
        guard ReachabilityHelper.checkConnection() else {
            return
        }
        AuthService().logOut()
        AuthService().anonymousLogIn(
            completion: { object in
                self.router.goToFeed()
            }, failure: { error in
                if let error = error {
                    handleError(error)
                }
            }
        )
    }
    
    dynamic private func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
                if kbHeight == 0 {
                    kbHeight = keyboardSize.height
                    animateTextField(true)
                }
                kbHidden = false
            }
        }
    }
    
    dynamic private func keyboardWillHide(notification: NSNotification) {
        animateTextField(false)
        kbHidden = true
        kbHeight = 0
    }
    
    private func animateTextField(up: Bool) {
        let movement = up ? kbHeight : -kbHeight
        bottomConstraint.constant = kbHidden ? movement / 2 : 0
        topConstraint.constant = kbHidden ? -movement / 2 : 0
        view.needsUpdateConstraints()
        UIView.animateWithDuration(
            0.3,
            animations: {
                self.view.layoutIfNeeded()
            }
        )
    }
    
    dynamic private func dismissKeyboard() {
        view.endEditing(true)
        kbHidden = true
    }
    
    private func handlePhotoSelected(image: UIImage) {
        setSelectedPhoto(image)
        navigationItem.rightBarButtonItem!.enabled = true
        someChangesMade = true
    }
    
    private func setSelectedPhoto(image: UIImage) {
        avatarImageView.image = image
        self.image = image
    }
    
    private func saveChanges() {
        someChangesMade = false
        guard let image = image else {
            return
        }
        let pictureData = UIImageJPEGRepresentation(image, 1)
        guard let file = PFFile(name: Constants.UserKey.Avatar, data: pictureData!) else {
            return
        }
        view.makeToastActivity(CSToastPositionCenter)
        view.userInteractionEnabled = false
        SaverService.uploadUserChanges(
            User.currentUser()!,
            avatar: file,
            nickname: userName,
            completion: { _, error in
                if let error = error {
                    print(error)
                }
                self.view.hideToastActivity()
                self.view.userInteractionEnabled = true
            }
        )
        navigationController!.popToRootViewControllerAnimated(true)
    }
    
    @IBAction private func avatarTapAction(sender: AnyObject) {
        photoGenerator.showInView(self)
    }
    
    @IBAction private func logoutAction() {
        let alertController = UIAlertController(
            title: nil,
            message: logoutMessage,
            preferredStyle: .ActionSheet
        )
        
        let cancelAction = UIAlertAction(
            title: "Cancel",
            style: .Cancel
            ) { _ in
                PushNotificationQueue.handleNotificationQueue()
                alertController.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        let okAction = UIAlertAction(
            title: "Logout me!",
            style: .Default
            ) { _ in
                self.logout()
        }
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction private func searchTextFieldValueChanged(sender: UITextField) {
        let afterStr = sender.text
        if userName != afterStr {
            userName = afterStr
            navigationItem.rightBarButtonItem!.enabled = true
            someChangesMade = true
        }
    }
    
}

extension EditProfileViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
