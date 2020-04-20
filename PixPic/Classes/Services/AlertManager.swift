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
private let simpleAlertDuration: TimeInterval = 2
private let notificationAlertDuration: TimeInterval = 3
private let cancelActionTitle = NSLocalizedString("cancel", comment: "")
private let registerActionTitle = NSLocalizedString("register", comment: "")

enum LoginNecessityReason: String {
    
    case Like = "can't_like_no_registration"
    case Follow = "can't_follow_no_registration"
    case Common = "need_registration"
    
}

protocol AlertManagerDelegate: FeedPresenter, ProfilePresenter, AuthorizationPresenter {

    func showSimpleAlert(_ message: String)
    func showNotificationAlert(_ userInfo: [AnyHashable: Any]?, message: String?)
    func suggestLogin(_ reason: LoginNecessityReason)

}

extension AlertManagerDelegate {

    func showSimpleAlert(_ message: String) {
        let style = CSToastStyle(defaultStyle: ())
        currentViewController.view.makeToast(message,
                                             duration: simpleAlertDuration,
                                             position: CSToastPositionBottom,
                                             style: style)
    }

    func showNotificationAlert(_ userInfo: [AnyHashable: Any]?, message: String?) {
        let title = notification
        var message = message
        guard let notificationObject = RemoteNotificationParser.parse(userInfo) else {
            return
        }

        switch notificationObject {
        case .newPost(let alert, _):
            message = alert

        case .newFollower(let alert, _):
            message = alert

        case .newLikedPost(let alert, _):
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

    func suggestLogin(_ reason: LoginNecessityReason) {
        let alertTitle =  NSLocalizedString(reason.rawValue, comment: "")
        let alertController = UIAlertController(title: alertTitle, message: "", preferredStyle: .alert)
        let cancelAction = UIAlertAction.appAlertAction( title: cancelActionTitle, style: .Cancel, handler: nil)

        let registerAction = UIAlertAction.appAlertAction(title: registerActionTitle, style: .Default) { [weak self] _ in
            self?.showAuthorization()
        }

        alertController.addAction(cancelAction)
        alertController.addAction(registerAction)

        currentViewController.present(alertController, animated: true, completion: nil)
    }

}

final class AlertManager {

    static let sharedInstance = AlertManager()

    fileprivate weak var delegate: AlertManagerDelegate?

    fileprivate init() {
    }

    func setAlertDelegate(_ delegate: AlertManagerDelegate) {
        self.delegate = delegate
    }

    func showSimpleAlert(_ message: String) {
        delegate?.showSimpleAlert(message)
    }

    func showNotificationAlert(_ userInfo: [AnyHashable: Any]?, message: String?) {
        delegate?.showNotificationAlert(userInfo, message: message)
    }

    func showLoginAlert(_ reason: LoginNecessityReason = .Common) {
        delegate?.suggestLogin(reason)
    }

    func handlePush(_ userInfo: [AnyHashable: Any]) {
        let application = UIApplication.shared

        switch application.applicationState {
        case .active:
            showNotificationAlert(userInfo, message: nil)
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)

        case .inactive:
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
            if let notificationObject = RemoteNotificationParser.parse(userInfo) {
                switch notificationObject {
                case .newFollower(_, let userId):
                    DispatchQueue.main.async {
                        self.delegate?.showProfile(userId)
                    }

                case .newLikedPost(_, let likedPostId):
                    DispatchQueue.main.async {
                        self.delegate?.showMyProfileWithPost(likedPostId)
                    }

                default:
                    NotificationCenter.default.post(
                        name: Notification.Name(rawValue: Constants.NotificationName.newPostIsReceaved),
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
