//
//  ActivityViewController.swift
//  PixPic
//
//  Created by Jack Lapin on 02.03.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class ActivityViewController: UIActivityViewController {

    fileprivate let facebookMessage = NSLocalizedString("posted_FB", comment: "")
    fileprivate let twitterMessage = NSLocalizedString("posted_TW", comment: "")
    fileprivate let cameraRollMessage = NSLocalizedString("saved_to_lib", comment: "")
    fileprivate let vkMessage = NSLocalizedString("posted_VK", comment: "")
    fileprivate let applyToContactMessage = NSLocalizedString("applied_to_contact", comment: "")
    fileprivate let doneMessage = NSLocalizedString("shared", comment: "")

    fileprivate let activityTypePostToVK = "com.vk.vkclient.shareextension"

    static func initWith(_ items: [AnyObject]) -> ActivityViewController {
        let activityViewController = ActivityViewController(activityItems: items, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [
            UIActivityType.postToTencentWeibo,
            UIActivityType.postToWeibo,
            UIActivityType.print,
            UIActivityType.openInIBooks
        ]
        activityViewController.completionWithItemsHandler = { activity, success, items, error in
            if let error = error {
                log.debug(error.localizedDescription)
            }
            if let activity = activity, success {
                let message = activityViewController.activityViewController(
                    activityViewController,
                    itemForActivityType: activity
                    ) as? String
                AlertManager.sharedInstance.showSimpleAlert(message!)
            }
        }

        return activityViewController
    }

}

// MARK: - UIActivityItemSource methods
extension ActivityViewController: UIActivityItemSource {

    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return ""
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType) -> Any? {
        switch activityType {
        case UIActivityType.postToFacebook:
            return facebookMessage

        case UIActivityType.postToTwitter:
            return twitterMessage

        case UIActivityType.saveToCameraRoll:
            return cameraRollMessage

        case UIActivityType.assignToContact:
            return applyToContactMessage

        case activityTypePostToVK:
            return vkMessage

        default:
            return doneMessage
        }
    }

}
