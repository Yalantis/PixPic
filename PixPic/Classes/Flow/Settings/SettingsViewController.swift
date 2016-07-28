//
//  SettingsViewController.swift
//  PixPic
//
//  Created by AndrewPetrov on 3/1/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

typealias SettingsRouterInterface = protocol<FeedPresenter, AlertManagerDelegate, AuthorizationPresenter>

private let logoutMessage = NSLocalizedString("will_logout", comment: "")
private let cancelActionTitle = NSLocalizedString("cancel", comment: "")
private let okActionTitle = NSLocalizedString("logout_me", comment: "")

private let enableNotificationsNibName = NSLocalizedString("enable_notifications", comment: "")
private let followedPostsNibName = NSLocalizedString("only_following_users_posts", comment: "")

private let logInString = NSLocalizedString("log_in", comment: "")
private let logOutString = NSLocalizedString("log_out", comment: "")

enum SettingsState {
    case Common, LoggedIn, LoggedOut
}

final class SettingsViewController: BaseUIViewController, StoryboardInitiable {
    
    @IBOutlet private weak var logInButton: UIButton!
    @IBOutlet private weak var logOutButton: UIButton!
    
    static let storyboardName = Constants.Storyboard.Settings
    var router: SettingsRouterInterface!
    
    private lazy var enableNotifications = SwitchView.instanceFromNib(enableNotificationsNibName, initialState: SettingsHelper.isRemoteNotificationsEnabled) { switchState in
        SettingsHelper.isRemoteNotificationsEnabled = switchState
    }
    private lazy var followedPosts = SwitchView.instanceFromNib(followedPostsNibName, initialState: SettingsHelper.isShownOnlyFollowingUsersPosts) { switchState in
        SettingsHelper.isShownOnlyFollowingUsersPosts = switchState
        NSNotificationCenter.defaultCenter().postNotificationName(
            Constants.NotificationName.NewPostIsUploaded,
            object: nil
        )
    }
    
    private var settings = [SettingsState: [UIView]]()
    private weak var locator: ServiceLocator!
    
    @IBOutlet private weak var versionLabel: UILabel!
    @IBOutlet private weak var settingsStack: UIStackView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAvailableSettings()
        updateVersionLabel()
        
        logInButton.setTitle(logInString, forState: .Normal)
        logOutButton.setTitle(logOutString, forState: .Normal)
    }
    
    // MARK: - Setup methods
    func setLocator(locator: ServiceLocator) {
        self.locator = locator
    }
    
    // MARK: - Private methods
    private func setupAvailableSettings() {
        settings[.Common] = [enableNotifications]
        for view in settings[.Common]! {
            settingsStack.addArrangedSubview(view)
        }
        let currentUser = User.currentUser()
        let notAuthorized = User.notAuthorized
        
        if currentUser != nil && notAuthorized == false {
            settings[.LoggedIn] = [followedPosts]
            for view in settings[.LoggedIn]! {
                settingsStack.addArrangedSubview(view)
            }
        }
        logInButton.hidden = !notAuthorized
        logOutButton.hidden = notAuthorized
        
    }
    
    private func updateVersionLabel() {
        let version = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"]!
        versionLabel.text = "PixPic v. \(version)"
    }
    
    @IBAction private func logout(sender: AnyObject) {
        guard ReachabilityHelper.isReachable() else {
            ExceptionHandler.handle(Exception.NoConnection)
            
            return
        }
        let authenticationService: AuthenticationService = locator.getService()
        authenticationService.logOut()
        authenticationService.anonymousLogIn(
            completion: { _ in
                self.router.showFeed()
            }, failure: { error in
                if let error = error {
                    ErrorHandler.handle(error)
                }
            }
        )
    }
    
    @IBAction private func logIn(sender: AnyObject) {
        self.router.showAuthorization()
    }
    
    private func showlogOutAlert() {
        let alertController = UIAlertController(
            title: nil,
            message: logoutMessage,
            preferredStyle: .ActionSheet
        )
        
        let cancelAction = UIAlertAction.appAlertAction(
            title: cancelActionTitle,
            style: .Cancel
        ) { _ in
            PushNotificationQueue.handleNotificationQueue()
            alertController.dismissViewControllerAnimated(true, completion: nil)
        }
        alertController.addAction(cancelAction)
        
        let okAction = UIAlertAction.appAlertAction(
            title: okActionTitle,
            style: .Default
        ) { _ in
            self.showlogOutAlert()
        }
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
    }
    
}

// MARK: - NavigationControllerAppearanceContext methods
extension SettingsViewController: NavigationControllerAppearanceContext {
    
    func preferredNavigationControllerAppearance(navigationController: UINavigationController) -> Appearance? {
        var appearance = Appearance()
        appearance.title = Constants.Settings.NavigationTitle
        return appearance
    }
    
}

