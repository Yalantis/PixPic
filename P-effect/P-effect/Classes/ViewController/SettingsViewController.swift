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

final class SettingsViewController: UIViewController, StoryboardInitable {
    
    static let storyboardName = Constants.Storyboard.Settings
    
    var router: protocol<FeedPresenter, AlertManagerDelegate, CredentialsPresenter, AuthorizationPresenter>!
    private weak var locator: ServiceLocator!
    
    @IBOutlet private weak var logOutView: UIView!
    @IBOutlet private weak var logInView: UIView!
    @IBOutlet private weak var showFollowedPostsView: UIView!
    @IBOutlet private weak var notificationSwitch: UISwitch!
    
    func setLocator(locator: ServiceLocator) {
        self.locator = locator
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = title
        
        notificationSwitch.on = SettingsHelper.notificationsState!
        
        let currentUser = User.currentUser()
        let isUserAbsent = currentUser == nil
        
        if PFAnonymousUtils.isLinkedWithUser(currentUser) || isUserAbsent {
            logOutView.removeFromSuperview()
            showFollowedPostsView.removeFromSuperview()
        } else if currentUser != nil {
            logInView.removeFromSuperview()
        }
    }
    
    @IBAction private func enableNotifications(sender: AnyObject) {
        SettingsHelper.switchNotofications(toState: notificationSwitch.on)
    }
    
    @IBAction private func enableOnlyFollowedNotifications(sender: AnyObject) {
        //TODO: implement logic here
    }
    
    @IBAction private func loginAction() {
        router.showAuthorization()
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
    
    @IBAction private func showCredentials(sender: AnyObject) {
        router.showCredentials()
    }
    
    private func logout() {
        guard ReachabilityHelper.checkConnection() else {
            return
        }
        let authService: AuthService = locator.getService()
        authService.logOut()
        authService.anonymousLogIn(
            completion: { object in
                self.router.showFeed()
            }, failure: { error in
                if let error = error {
                    handleError(error)
                }
            }
        )
    }
    
}
