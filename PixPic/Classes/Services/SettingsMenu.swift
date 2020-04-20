//
//  SettingsMenu.swift
//  PixPic
//
//  Created by anna on 3/24/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

private let removePostMessage = NSLocalizedString("photo_deleted", comment: "")
private let suggestLoginMessage = NSLocalizedString("need_registration", comment: "")
private let complaintMessage = NSLocalizedString("complaint_about", comment: "")

private let cancelActionTitle = NSLocalizedString("cancel", comment: "")
private let shareActionTitle = NSLocalizedString("share", comment: "")
private let removeActionTitle = NSLocalizedString("remove_post", comment: "")
private let complaintActionTitle = NSLocalizedString("complain", comment: "")
private let registerActionTitle = NSLocalizedString("register", comment: "")

class SettingsMenu: NSObject, UINavigationControllerDelegate {

    var locator: ServiceLocator!
    var postRemovalHandler: ((_ atIndex: Int) -> Void)!
    fileprivate var presenter: UIViewController!

    func showInViewController(_ controller: UIViewController, forPost post: Post, atIndex index: Int, items: [AnyObject]) {
        presenter = controller

        guard ReachabilityHelper.isReachable() else {
            ExceptionHandler.handle(Exception.NoConnection)

            return
        }
        if User.notAuthorized {
            AlertManager.sharedInstance.showLoginAlert()
        } else {
            let settingsMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction.appAlertAction(
                title: cancelActionTitle,
                style: .Cancel,
                handler: nil)
            settingsMenu.addAction(cancelAction)

            let shareAction = UIAlertAction.appAlertAction(
                title: shareActionTitle,
                style: .Default
                ) { [weak self] _ in
                    self?.showActivityController(withItems: items)
            }
            settingsMenu.addAction(shareAction)

            if let userFacebookId = post.user!.facebookId, let currentUserFacebookId = User.currentUser()!.facebookId, userFacebookId == currentUserFacebookId {
                let removeAction = UIAlertAction.appAlertAction(
                    title: removeActionTitle,
                    style: .Default
                    ) { [weak self] _ in
                        self?.removePost(post, atIndex: index)
                }
                settingsMenu.addAction(removeAction)
            } else {
                let complaintAction = UIAlertAction.appAlertAction(
                    title: complaintActionTitle,
                    style: .Default
                    ) { [weak self] _ in
                        self?.complaintToPost(post)
                }
                settingsMenu.addAction(complaintAction)
            }
            controller.present(settingsMenu, animated: true, completion: nil)
        }
    }

    fileprivate func removePost(_ post: Post, atIndex index: Int) {
        UIAlertController.showAlert(
            inViewController: presenter,
            message: removePostMessage) { [weak self] _ in
                guard let this = self else {
                    return
                }

                let postService: PostService = this.locator.getService()
                postService.removePost(post) { succeeded, error in
                    if succeeded {
                        this.postRemovalHandler(atIndex: index)
                    } else if let error = error?.localizedDescription {
                        log.debug(error)
                    }
                }
        }
    }

    fileprivate func complaintToPost(_ post: Post) {
        let complaintMenu = UIAlertController(title: complaintMessage, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction.appAlertAction(
            title: cancelActionTitle,
            style: .Cancel,
            handler: nil)
        complaintMenu.addAction(cancelAction)

        let complaintService: ComplaintService = locator.getService()
        let complainAboutUsernameAction = UIAlertAction.appAlertAction(
            title: NSLocalizedString("\(ComplaintReason.Username.rawValue)", comment: ""),
            style: .Default
            ) { _ in
                complaintService.complainAboutUsername(post.user!) { _, error in
                    log.debug(error?.localizedDescription)
                }
        }

        let complainAboutUserAvatarAction = UIAlertAction.appAlertAction(
            title: NSLocalizedString("\(ComplaintReason.UserAvatar.rawValue)", comment: ""),
            style: .Default
            ) { _ in
                complaintService.complainAboutUserAvatar(post.user!) { _, error in
                    log.debug(error?.localizedDescription)
                }
        }

        let complainAboutPostAction = UIAlertAction.appAlertAction(
            title: NSLocalizedString("\(ComplaintReason.PostImage.rawValue)", comment: ""),
            style: .Default
            ) { _ in
                complaintService.complainAboutPost(post) { _, error in
                    log.debug(error?.localizedDescription)
                }
        }

        complaintMenu.addAction(complainAboutUsernameAction)
        complaintMenu.addAction(complainAboutUserAvatarAction)
        complaintMenu.addAction(complainAboutPostAction)

        presenter.present(complaintMenu, animated: true, completion: nil)
    }

    fileprivate func showActivityController(withItems items: [AnyObject]) {
        let activityViewController = ActivityViewController.initWith(items)
        presenter.present(activityViewController, animated: true, completion: nil)
    }

}
