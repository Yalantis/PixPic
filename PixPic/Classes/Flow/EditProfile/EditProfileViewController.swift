//
//  EditProfileViewController.swift
//  PixPic
//
//  Created by Jack Lapin on 20.01.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import Toast

typealias EditProfileRouterInterface = AuthorizationRouterInterface

private let saveChangesWithoutConnectionMessage = NSLocalizedString("internet_required_to_change_profile", comment: "")
private let logoutMessage = NSLocalizedString("will_logout", comment: "")
private let backWithChangesMessage = NSLocalizedString("changes_will_be_discarded", comment: "")
private let logoutWithoutConnectionAttempt = NSLocalizedString("internet_required_to_logout", comment: "")
private let backWithChangesTitle = NSLocalizedString("save_changes", comment: "")
private let saveActionTitle = NSLocalizedString("save", comment: "")
private let logoutActionTitle = NSLocalizedString("logout_me", comment: "")
private let cancelActionTitle = NSLocalizedString("cancel", comment: "")
private let okActionTitle = NSLocalizedString("ok", comment: "")
private let textFieldAnimationDuration: TimeInterval = 0.3
private let nickNameTextFieldUnderlineOffset: CGFloat = 20

final class EditProfileViewController: BaseUIViewController, StoryboardInitiable {

    static let storyboardName = Constants.Storyboard.profile

    fileprivate var router: EditProfileRouterInterface!

    fileprivate lazy var photoProvider = PhotoProvider()

    fileprivate var image: UIImage?
    fileprivate var userName: String?
    fileprivate var originalUserName: String?

    fileprivate var kbHeight: CGFloat = 0
    fileprivate var kbHidden = true
    fileprivate var someChangesMade = false
    fileprivate var usernameChanged = false
    fileprivate weak var locator: ServiceLocator!

    @IBOutlet fileprivate weak var avatarImageView: UIImageView!
    @IBOutlet fileprivate weak var nickNameTextField: UITextField!

    @IBOutlet fileprivate weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var unlerlineWidth: NSLayoutConstraint!

    @IBOutlet fileprivate weak var saveButton: UIButton!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        makeNavigation()
        view.layoutIfNeeded()
        configureImagesAndText()
        subscribeOnNotifications()
        changeNickNameTextFieldWidth()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        AlertManager.sharedInstance.setAlertDelegate(router)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        PushNotificationQueue.handleNotificationQueue()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2
    }

    // MARK: - Setup methods
    func setLocator(_ locator: ServiceLocator) {
        self.locator = locator
    }

    func setRouter(_ router: EditProfileRouterInterface) {
        self.router = router
    }

    // MARK: - Private methods
    fileprivate func subscribeOnNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: NSNotification.Name.UIKeyboardWillHide,
            object: nil
        )
    }

    fileprivate func configureImagesAndText() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)

        photoProvider.didSelectPhoto = { [weak self] selectedImage in
            self?.handlePhotoSelected(selectedImage)
        }
        avatarImageView.layer.masksToBounds = true
        saveButton.isEnabled = false
        nickNameTextField.text = User.currentUser()?.username
        userName = User.currentUser()?.username
        originalUserName = userName
        guard let avatar = User.currentUser()?.avatar else {
            return
        }
        avatar.getImage { [weak self] image, error in
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

    fileprivate func makeNavigation() {
        let leftButton = UIBarButtonItem(
            image: UIImage.appBackButton,
            style: .plain,
            target: self,
            action: #selector(handleBackButtonTap)
        )
        navigationItem.leftBarButtonItem = leftButton
    }

    @objc fileprivate func handleBackButtonTap() {
        if someChangesMade {
            let alertController = UIAlertController(
                title: backWithChangesTitle,
                message: backWithChangesMessage, preferredStyle: .alert
            )
            let noAction = UIAlertAction.appAlertAction(
                title: okActionTitle,
                style: .Cancel
                ) { [weak self] action in
                    PushNotificationQueue.handleNotificationQueue()
                    alertController.dismissViewControllerAnimated(true, completion: nil)
                    self?.navigationController?.popViewControllerAnimated(true)
            }
            alertController.addAction(noAction)

            let yesAction = UIAlertAction.appAlertAction(
                title: saveActionTitle,
                style: .Default
                ) { [weak self] action in
                    self?.saveChangesAction()
                    PushNotificationQueue.handleNotificationQueue()
            }
            alertController.addAction(yesAction)

            self.presentViewController(alertController, animated: true) {}
        } else {
            navigationController?.popViewControllerAnimated(true)
        }
    }

    @IBAction func saveChangesAction() {
        saveButton.isEnabled = false
        if ReachabilityHelper.isReachable() {
            guard let userName = userName, originalUserName != userName else {
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

    @objc fileprivate func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            if let keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                if kbHeight == 0 {
                    kbHeight = keyboardSize.height
                    animateTextField(true)
                }
                kbHidden = false
            }
        }
    }

    @objc fileprivate func keyboardWillHide(_ notification: Notification) {
        animateTextField(false)
        kbHidden = true
        kbHeight = 0
    }

    fileprivate func animateTextField(_ up: Bool) {
        let movement = up ? kbHeight : -kbHeight
        bottomConstraint.constant = kbHidden ? movement / 2 : 0
        topConstraint.constant = kbHidden ? -movement / 2 : 0
        view.needsUpdateConstraints()
        UIView.animateWithDuration(
            textFieldAnimationDuration,
            animations: {
                self.view.layoutIfNeeded()
            }
        )
    }

    @objc fileprivate func dismissKeyboard() {
        view.endEditing(true)
        kbHidden = true
    }

    fileprivate func handlePhotoSelected(_ image: UIImage) {
        setSelectedPhoto(image)
        saveButton.isEnabled = true
        someChangesMade = true
        navigationController?.popToViewController(self, animated: true)
    }

    fileprivate func setSelectedPhoto(_ image: UIImage) {
        avatarImageView.image = image
        self.image = image
    }

    fileprivate func saveChanges() {
        someChangesMade = false
        guard let image = image else {
            return
        }
        let pictureData = UIImageJPEGRepresentation(image, 1)
        guard let file = PFFile(name: Constants.UserKey.avatar, data: pictureData!) else {
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
        navigationController?.popToRootViewControllerAnimated(true)
    }

    // MARK: - IBActions
    @IBAction fileprivate func avatarTapAction(_ sender: AnyObject) {
        photoProvider.presentPhotoOptionsDialog(in: self)
    }

    @IBAction fileprivate func searchTextFieldValueChanged(_ sender: UITextField) {
        let afterStr = sender.text
        if userName != afterStr {
            userName = afterStr
            saveButton.isEnabled = true
            someChangesMade = true
        }
    }

    @IBAction func changeNickNameTextFieldWidth() {
        if let width = nickNameTextField.attributedText?.size().width {
             unlerlineWidth.constant = width + nickNameTextFieldUnderlineOffset
        }
    }

}

// MARK: - UITextFieldDelegate methods
extension EditProfileViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        return false
    }

}

// MARK: - NavigationControllerAppearanceContext methods
extension EditProfileViewController: NavigationControllerAppearanceContext {

    func preferredNavigationControllerAppearance(_ navigationController: UINavigationController) -> Appearance? {
        var appearance = Appearance()
        appearance.title = Constants.EditProfile.navigationTitle
        return appearance
    }

}
