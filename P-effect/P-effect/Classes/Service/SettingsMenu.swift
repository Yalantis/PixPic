//
//  SettingsMenu.swift
//  P-effect
//
//  Created by anna on 3/24/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

private let removePostMessage = "This photo will be deleted from P-effect"

class SettingsMenu: NSObject, UINavigationControllerDelegate {
    
    private var controller: UIViewController!
    var completionAuthorizeUser:(() -> Void)!
    var completionRemovePost:((atIndex: Int) -> Void)!
    
    func showInViewController(controller: UIViewController, forPost post: Post, atIndex index: Int, items: [AnyObject]) {
        self.controller = controller

        let reachabilityService =  ReachabilityService()
        guard reachabilityService.isReachable() else {
            ExceptionHandler.handle(Exception.NoConnection)
            
            return
        }
        if User.notAuthorized {
            suggestLogin()
        } else {
            let settingsMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            settingsMenu.addAction(cancelAction)
            
            let shareAction = UIAlertAction(title: "Share", style: .Default) { [weak self] _ in
                self?.showActivityController(items)
            }
            settingsMenu.addAction(shareAction)
            
            if post.user == User.currentUser() {
                let removeAction = UIAlertAction(title: "Remove post", style: .Default) { [weak self] _ in
                    self?.removePost(post, atIndex: index)
                }
                settingsMenu.addAction(removeAction)
            } else {
                let complaintAction = UIAlertAction(title: "Complain", style: .Default) { [weak self] _ in
                    self?.complaintToPost(post)
                }
                settingsMenu.addAction(complaintAction)
            }
            controller.presentViewController(settingsMenu, animated: true, completion: nil)
        }
    }
    
    private func suggestLogin() {
        let alertController = UIAlertController(title: "You can't use this function without registration", message: "", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        let registerAction = UIAlertAction(title: "Register", style: .Default) { [weak self] _ in
            self?.completionAuthorizeUser()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(registerAction)
        
        controller.presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func removePost(post: Post, atIndex index: Int) {
        UIAlertController.showAlert(
            inViewController: controller,
            message: removePostMessage) { [weak self] _ in
                guard let this = self else {
                    return
                }
                
                let postService = PostService()
                postService.removePost(post) { succeeded, error in
                    if succeeded {
                        this.completionRemovePost(atIndex: index)
                    } else if let error = error?.localizedDescription {
                        log.debug(error)
                    }
                }
        }
    }
    
    private func complaintToPost(post: Post) {
        let complaintMenu = UIAlertController(title: "Complaint about", message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        complaintMenu.addAction(cancelAction)
        
        let complaintService = ComplaintService()
        
        let complaintUsernameAction = UIAlertAction(title: "Username", style: .Default) { _ in
            complaintService.complaintUsername(post.user!) { _, error in
                log.debug(error?.localizedDescription)
            }
        }
        
        let complaintUserAvatarAction = UIAlertAction(title: "User avatar", style: .Default) { _ in
            complaintService.complaintUserAvatar(post.user!) { _, error in
                log.debug(error?.localizedDescription)
            }
        }
        
        let complaintPostAction = UIAlertAction(title: "Post", style: .Default) { _ in
            complaintService.complaintPost(post) { _, error in
                log.debug(error?.localizedDescription)
            }
        }
        
        complaintMenu.addAction(complaintUsernameAction)
        complaintMenu.addAction(complaintUserAvatarAction)
        complaintMenu.addAction(complaintPostAction)
        
        controller.presentViewController(complaintMenu, animated: true, completion: nil)
    }
    
    private func showActivityController(items: [AnyObject]) {
        let activityViewController = ActivityViewController.initWith(items)
        controller.presentViewController(activityViewController, animated: true, completion: nil)
    }

}
