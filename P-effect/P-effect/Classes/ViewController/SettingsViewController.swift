//
//  SettingsViewController.swift
//  P-effect
//
//  Created by AndrewPetrov on 3/1/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

private let logoutMessage = "This will logout you. And you will not be able to share your amazing photos..("
private let title = "Settings"

enum SettingsState {
    
    case Common, LoggedIn, LoggedOut
    
}

final class SettingsViewController: UIViewController, StoryboardInitable, NavigationControllerAppearanceContext {
    
    static let storyboardName = Constants.Storyboard.Settings
    var router: protocol<FeedPresenter, AlertManagerDelegate, CredentialsPresenter, AuthorizationPresenter>!
    
    private lazy var credentials: UIView = TextView.instanceFromNib("Credentials/Policies") {
        self.router.showCredentials()
    }
    private lazy var enableNotifications: UIView = SwitchView.instanceFromNib("Enable Notifications", initialState: SettingsHelper.isRemoteNotificationsEnabled) { on in
        SettingsHelper.isRemoteNotificationsEnabled = on
    }
    private lazy var followedPosts: UIView = SwitchView.instanceFromNib("Show only following users posts") { on in
        //TODO: implement logic here
    }
    private lazy var logIn: UIView = ButtonView.instanceFromNib("Log In") {
        self.router.showAuthorization()
    }
    private lazy var logOut: UIView = ButtonView.instanceFromNib("Log Out") {
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
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    private var settings = [SettingsState: [UIView]]()
    private weak var locator: ServiceLocator!
    
    @IBOutlet private weak var settingsStack: UIStackView!
    
    func setLocator(locator: ServiceLocator) {
        self.locator = locator
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = title
        setupAvailableSettings()
    }
    
    private func setupAvailableSettings() {
        settings[.Common] = [credentials, enableNotifications]
        for view in settings[.Common]! {
            settingsStack.addArrangedSubview(view)
        }
        let currentUser = User.currentUser()
        if User.notAuthorized {
            settings[.LoggedOut] = [logIn]
            for view in settings[.LoggedOut]! {
                settingsStack.addArrangedSubview(view)
            }
        } else if currentUser != nil {
            settings[.LoggedIn] = [followedPosts, logOut]
            for view in settings[.LoggedIn]! {
                settingsStack.addArrangedSubview(view)
            }
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
            completion: { _ in
                self.router.showFeed()
            }, failure: { error in
                if let error = error {
                    handleError(error)
                }
            }
        )
    }
    
}
