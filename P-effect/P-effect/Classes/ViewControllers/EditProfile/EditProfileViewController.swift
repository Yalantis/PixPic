//
//  EditProfileViewController.swift
//  P-effect
//
//  Created by Jack Lapin on 20.01.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import Toast

private let saveChangesWithoutConnectionMessage = "Internet connection is required to save changes in profile"
private let logoutMessage = "This will logout you. And you will not be able to share your amazing photos..("
private let backWithChangesMessage = "If you go back now, your changes will be discarded"
private let logoutWithoutConnectionAttempt = "Internet connection is required to logout"
private let backWithChangesTitle = "Save changes"
private let saveActionTitle = "Save"
private let logoutActionTitle = "Logout me!"
private let cancelActionTitle = "Cancel"
private let okActionTitle = "Ok"

final class EditProfileViewController: UIViewController, StoryboardInitable {
    
    static let storyboardName = Constants.Storyboard.Profile
    
    private var router: RouterInterface!
    
    private lazy var photoGenerator = PhotoGenerator()
    
    private var image: UIImage?
    private var userName: String?
    private var originalUserName: String?
    
    private var kbHeight: CGFloat = 0.0
    private var kbHidden = true
    private var someChangesMade = false
    private var usernameChanged = false
    private weak var locator: ServiceLocator!
    
    @IBOutlet private weak var avatarImageView: UIImageView!
    @IBOutlet private weak var nickNameTextField: UITextField!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var topConstraint: NSLayoutConstraint!
   
    // MARK: - Lifecycle
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
        
        AlertManager.sharedInstance.setAlertDelegate(router)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        PushNotificationQueue.handleNotificationQueue()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2.0
    }
    
    // MARK: - Setup methods
    func setLocator(locator: ServiceLocator) {
        self.locator = locator
    }
    
    func setRouter(router: RouterInterface) {
        self.router = router
    }
    
    // MARK: - Private methods
    private func subscribeOnNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIKeyboardWillShowNotification,
            object: nil
        )
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIKeyboardWillHideNotification,
            object: nil
        )
    }
    
    private func configureImagesAndText() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        photoGenerator.didSelectPhoto = { [weak self] selectedImage in
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
        ImageLoaderHelper.getImageForContentItem(avatar) { [weak self] image, error in
            guard let this = self else {
                return
            }
            if let error = error {
                log.debug(error.localizedDescription)
            } else {
                this.avatarImageView.image = image
                this.image = image
            }
        }
    }
    
    private func makeNavigation() {
        let rightButton = UIBarButtonItem(
            title: saveActionTitle,
            style: .Plain,
            target: self,
            action: #selector(saveChangesAction)
        )
        navigationItem.rightBarButtonItem = rightButton
        
        let leftButton = UIBarButtonItem(
            image: UIImage.appBackButton(),
            style: .Plain,
            target: self,
            action: #selector(handleBackButtonTap)
        )
        navigationItem.leftBarButtonItem = leftButton
    }
    
    @objc private func handleBackButtonTap() {
        if someChangesMade {
            let alertController = UIAlertController(
                title: backWithChangesTitle,
                message: backWithChangesMessage, preferredStyle: .Alert
            )
            let noAction = UIAlertAction(
                title: okActionTitle,
                style: .Cancel
                ) { [weak self] action in
                    PushNotificationQueue.handleNotificationQueue()
                    alertController.dismissViewControllerAnimated(true, completion: nil)
                    self?.navigationController!.popViewControllerAnimated(true)
            }
            alertController.addAction(noAction)
            
            let yesAction = UIAlertAction(
                title: saveActionTitle,
                style: .Default
                ) { [weak self] action in
                    self?.saveChangesAction()
                    PushNotificationQueue.handleNotificationQueue()
            }
            alertController.addAction(yesAction)
            
            self.presentViewController(alertController, animated: true) {}
        } else {
            navigationController!.popViewControllerAnimated(true)
        }
    }
    
    @objc private func saveChangesAction() {
        navigationItem.rightBarButtonItem!.enabled = false
        if ReachabilityHelper.isReachable() {
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
            AlertManager.sharedInstance.showSimpleAlert(saveChangesWithoutConnectionMessage)
        }
    }
    
    private func logout() {
        guard ReachabilityHelper.isReachable() else {
            ExceptionHandler.handle(Exception.NoConnection)
            
            return
        }
        let authService: AuthService = locator.getService()
        authService.logOut()
        authService.anonymousLogIn(
            completion: { object in
                self.router.showFeed()
            }, failure: { error in
                if let error = error {
                    ErrorHandler.handle(error)
                }
            }
        )
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
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
    
    @objc private func keyboardWillHide(notification: NSNotification) {
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
    
    @objc private func dismissKeyboard() {
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
        let userService: UserService = locator.getService()
        userService.uploadUserChanges(
            User.currentUser()!,
            avatar: file,
            nickname: userName!,
            completion: { _, error in
                if let error = error {
                    log.debug(error)
                }
                self.view.hideToastActivity()
                self.view.userInteractionEnabled = true
            }
        )
        navigationController!.popToRootViewControllerAnimated(true)
    }
    
    // MARK: - IBActions
    @IBAction private func avatarTapAction(sender: AnyObject) {
        photoGenerator.showListOfOptions(inViewController: self)
    }
    
    @IBAction private func logoutAction() {
        let alertController = UIAlertController(
            title: nil,
            message: logoutMessage,
            preferredStyle: .ActionSheet
        )
        
        let cancelAction = UIAlertAction(
            title: cancelActionTitle,
            style: .Cancel
            ) { _ in
                PushNotificationQueue.handleNotificationQueue()
                alertController.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        let okAction = UIAlertAction(
            title: logoutActionTitle,
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

// MARK: - UITextFieldDelegate methods
extension EditProfileViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return false
    }
}

// MARK: - NavigationControllerAppearanceContext methods
extension EditProfileViewController: NavigationControllerAppearanceContext {
    
    func preferredNavigationControllerAppearance(navigationController: UINavigationController) -> Appearance? {
        var appearance = Appearance()
        appearance.title = Constants.EditProfile.NavigationTitle
        return appearance
    }
    
}
