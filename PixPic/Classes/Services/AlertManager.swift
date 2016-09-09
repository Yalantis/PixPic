//
//  AlertManager.swift
//  PixPic
//
//  Created by Jack Lapin on 17.01.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import Toast

private let notification = NSLocalizedString("notification", comment: "")
private let simpleAlertDuration: NSTimeInterval = 2
private let notificationAlertDuration: NSTimeInterval = 3
private let cancelActionTitle = NSLocalizedString("cancel", comment: "")
private let registerActionTitle = NSLocalizedString("register", comment: "")

enum LoginNecessityReason: String {
    
    case Like = "can't_like_no_registration"
    case Follow = "can't_follow_no_registration"
    case Common = "need_registration"
    
}

protocol AlertManagerDelegate: FeedPresenter, ProfilePresenter, AuthorizationPresenter {

    func showSimpleAlert(message: String)
    func showNotificationAlert(userInfo: [NSObject: AnyObject]?, message: String?)
    func suggestLogin(reason: LoginNecessityReason)

}

extension AlertManagerDelegate {

    func showSimpleAlert(message: String) {
        let style = CSToastStyle(defaultStyle: ())
        currentViewController.view.makeToast(message,
                                             duration: simpleAlertDuration,
                                             position: CSToastPositionBottom,
                                             style: style)
    }

    func showNotificationAlert(userInfo: [NSObject: AnyObject]?, message: String?) {
        let title = notification
        var message = message
        guard let notificationObject = RemoteNotificationParser.parse(userInfo) else {
            return
        }

        switch notificationObject {
        case .NewPost(let alert, _):
            message = alert

        case .NewFollower(let alert, _):
            message = alert

        case .NewLikedPost(let alert, _):
            message = alert
        }

        let isControllerWaitingForResponse = (currentViewController.presentedViewController as? UIAlertController) != nil

        let style = CSToastStyle(defaultStyle: ())
        if isControllerWaitingForResponse {
            PushNotificationQueue.addObjectToQueue(message)
        } else {
            PushNotificationQueue.clearQueue()
            currentViewController.view.makeToast(
                message,
                duration: notificationAlertDuration,
                position: CSToastPositionTop,
                title: title,
                image: UIImage(named: "icon_notification"),
                style: style,
                completion: { [weak self] didTap in
                    if didTap {
                        switch notificationObject {
                        case .NewFollower(_, let userId):
                            self?.showProfile(userId)
                            break

                        case .NewLikedPost(_, let postId):
                            self?.showMyProfileWithPost(postId)
                            break

                        default:
                            self?.showFeed()
                            break
                        }
                    }
                }
            )
        }
    }

    func suggestLogin(reason: LoginNecessityReason) {
        let alertTitle =  NSLocalizedString(reason.rawValue, comment: "")
        let alertController = UIAlertController(title: alertTitle, message: "", preferredStyle: .Alert)
        let cancelAction = UIAlertAction.appAlertAction( title: cancelActionTitle, style: .Cancel, handler: nil)

        let registerAction = UIAlertAction.appAlertAction(title: registerActionTitle, style: .Default) { [weak self] _ in
            self?.showAuthorization()
        }

        alertController.addAction(cancelAction)
        alertController.addAction(registerAction)

        currentViewController.presentViewController(alertController, animated: true, completion: nil)
    }

}

final class AlertManager {

    static let sharedInstance = AlertManager()

    private weak var delegate: AlertManagerDelegate?

    private init() {
    }

    func setAlertDelegate(delegate: AlertManagerDelegate) {
        self.delegate = delegate
    }

    func showSimpleAlert(message: String) {
        delegate?.showSimpleAlert(message)
    }

    func showNotificationAlert(userInfo: [NSObject: AnyObject]?, message: String?) {
        delegate?.showNotificationAlert(userInfo, message: message)
    }

    func showLoginAlert(reason: LoginNecessityReason = .Common) {
        delegate?.suggestLogin(reason)
    }

    func handlePush(userInfo: [NSObject: AnyObject]) {
        let application = UIApplication.sharedApplication()

        switch application.applicationState {
        case .Active:
            showNotificationAlert(userInfo, message: nil)
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)

        case .Inactive:
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
            if let notificationObject = RemoteNotificationParser.parse(userInfo) {
                switch notificationObject {
                case .NewFollower(_, let userId):
                    dispatch_async(dispatch_get_main_queue()) {
                        self.delegate?.showProfile(userId)
                    }

                case .NewLikedPost(_, let likedPostId):
                    dispatch_async(dispatch_get_main_queue()) {
                        self.delegate?.showMyProfileWithPost(likedPostId)
                    }

                default:
                    NSNotificationCenter.defaultCenter().postNotificationName(
                        Constants.NotificationName.newPostIsReceaved,
                        object: nil
                    )
                    delegate?.showFeed()
                }
            }

        default:
            break
        }
    }

}
