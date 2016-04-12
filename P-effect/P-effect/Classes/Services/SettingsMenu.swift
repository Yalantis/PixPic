//
//  SettingsMenu.swift
//  P-effect
//
//  Created by anna on 3/24/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

private let removePostMessage = "This photo will be deleted from P-effect"
private let suggestLoginMessage = "You can't use this function without registration"
private let complaintMessage = "Complaint about"

private let cancelActionTitle = "Cancel"
private let shareActionTitle = "Share"
private let removeActionTitle = "Remove post"
private let complaintActionTitle = "Complain"
private let registerActionTitle = "Register"

class SettingsMenu: NSObject, UINavigationControllerDelegate {
    
    var locator: ServiceLocator!
    var userAuthorizationHandler: (() -> Void)!
    var postRemovalHandler: ((atIndex: Int) -> Void)!
    private var presenter: UIViewController!

    func showInViewController(controller: UIViewController, forPost post: Post, atIndex index: Int, items: [AnyObject]) {
        presenter = controller

        guard ReachabilityHelper.isReachable() else {
            ExceptionHandler.handle(Exception.NoConnection)
            
            return
        }
        if User.notAuthorized {
            suggestLogin()
        } else {
            let settingsMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            let cancelAction = UIAlertAction(
                title: cancelActionTitle,
                style: .Cancel,
                handler: nil)
            settingsMenu.addAction(cancelAction)
            
            let shareAction = UIAlertAction(
                title: shareActionTitle,
                style: .Default
                ) { [weak self] _ in
                    self?.showActivityController(withItems: items)
            }
            settingsMenu.addAction(shareAction)
            
            if post.user == User.currentUser() {
                let removeAction = UIAlertAction(
                    title: removeActionTitle,
                    style: .Default
                    ) { [weak self] _ in
                        self?.removePost(post, atIndex: index)
                }
                settingsMenu.addAction(removeAction)
            } else {
                let complaintAction = UIAlertAction(
                    title: complaintActionTitle,
                    style: .Default
                    ) { [weak self] _ in
                        self?.complaintToPost(post)
                }
                settingsMenu.addAction(complaintAction)
            }
            controller.presentViewController(settingsMenu, animated: true, completion: nil)
        }
    }
    
    private func suggestLogin() {
        let alertController = UIAlertController(title: suggestLoginMessage, message: "", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(
            title: cancelActionTitle,
            style: .Cancel,
            handler: nil)
        
        let registerAction = UIAlertAction(
            title: registerActionTitle,
            style: .Default
            ) { [weak self] _ in
                self?.userAuthorizationHandler()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(registerAction)
        
        presenter.presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func removePost(post: Post, atIndex index: Int) {
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
    
    private func complaintToPost(post: Post) {
        let complaintMenu = UIAlertController(title: complaintMessage, message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(
            title: cancelActionTitle,
            style: .Cancel,
            handler: nil)
        complaintMenu.addAction(cancelAction)
        
        let complaintService: ComplaintService = locator.getService()
        let complainAboutUsernameAction = UIAlertAction(
            title: ComplaintReason.Username.rawValue,
            style: .Default
            ) { _ in
                complaintService.complainAboutUsername(post.user!) { _, error in
                    log.debug(error?.localizedDescription)
                }
        }
        
        let complainAboutUserAvatarAction = UIAlertAction(
            title: ComplaintReason.UserAvatar.rawValue,
            style: .Default
            ) { _ in
                complaintService.complainAboutUserAvatar(post.user!) { _, error in
                    log.debug(error?.localizedDescription)
                }
        }
        
        let complainAboutPostAction = UIAlertAction(
            title: ComplaintReason.PostImage.rawValue,
            style: .Default
            ) { _ in
                complaintService.complainAboutPost(post) { _, error in
                    log.debug(error?.localizedDescription)
                }
        }
        
        complaintMenu.addAction(complainAboutUsernameAction)
        complaintMenu.addAction(complainAboutUserAvatarAction)
        complaintMenu.addAction(complainAboutPostAction)
        
        presenter.presentViewController(complaintMenu, animated: true, completion: nil)
    }
    
    private func showActivityController(withItems items: [AnyObject]) {
        let activityViewController = ActivityViewController.initWith(items)
        presenter.presentViewController(activityViewController, animated: true, completion: nil)
    }

}
