//
//  ActivityViewController.swift
//  P-effect
//
//  Created by Jack Lapin on 02.03.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class ActivityViewController: UIActivityViewController {
    
    private let facebokMessage = "Posted on Facebook!"
    private let twitterMessage = "Tweeted!"
    private let cameraRollMessage = "Saved to Photos!"
    private let vkMessage = "Posted to VK!"
    private let applyToContactMessage = "Applied to contact!"
    private let doneMessage = "Shared!"
    
    static func initWith(items: [AnyObject]) -> ActivityViewController {
        let activityVC = ActivityViewController(activityItems: items, applicationActivities: nil)
        activityVC.excludedActivityTypes = [
            UIActivityTypePostToTencentWeibo,
            UIActivityTypePostToWeibo,
            UIActivityTypePrint,
            UIActivityTypeOpenInIBooks
        ]
        activityVC.completionWithItemsHandler = { activity, success, items, error in
            if let error = error {
                print(error)
            }
            if success {
                let message = activityVC.activityViewController(
                    activityVC,
                    itemForActivityType: activity!
                    ) as? String
                AlertManager.sharedInstance.showSimpleAlert(message!)
            }
        }
        return activityVC
    }
    
}

extension ActivityViewController: UIActivityItemSource {
    
    func activityViewControllerPlaceholderItem(activityViewController: UIActivityViewController) -> AnyObject {
        return ""
    }
    
    func activityViewController(activityViewController: UIActivityViewController, itemForActivityType activityType: String) -> AnyObject? {
        switch activityType {
        case UIActivityTypePostToFacebook:
            return facebokMessage
            
        case UIActivityTypePostToTwitter:
            return twitterMessage
            
        case UIActivityTypeSaveToCameraRoll:
            return cameraRollMessage
            
        case UIActivityTypeAssignToContact:
            return applyToContactMessage
            
        case "com.vk.vkclient.shareextension":
            return vkMessage
            
        default:
            return doneMessage
        }
    }
    
}