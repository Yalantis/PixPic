//
//  AlertService.swift
//  P-effect
//
//  Created by Jack Lapin on 17.01.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import Toast

protocol AlertServiceDelegate: class {
    
    func showSimpleAlert(message: String?)
    func showNotificationAlert(userInfo: [NSObject : AnyObject]?, var message: String?)
    
}

extension AlertServiceDelegate where Self: FeedPresenter {
    
    func showSimpleAlert(message: String?) {
        currentViewController.view.makeToast(message, duration: 2.0, position: CSToastPositionBottom)
    }
    
    func showNotificationAlert(userInfo: [NSObject : AnyObject]?, var message: String?) {
        let title = "Notification"
        
        guard let userInfo = userInfo else {
            return
        }
        
        if let aps = userInfo["aps"] as? [String: String] {
            message = aps["alert"]
        }
        
        let isControllersWaitingForResponse = (currentViewController as? UIAlertController) != nil
        
        if isControllersWaitingForResponse {
            PushNotificationQueue.addObjectInQueue(message)
        } else {
            PushNotificationQueue.clearQueue()
            currentViewController.view.makeToast(
                message,
                duration: 3.0,
                position: CSToastPositionTop,
                title: title,
                image: UIImage(named: "ic_notification"),
                style: nil,
                completion: {
                    (didTap: Bool) in
                    if didTap {
                        self.showFeed()
                    }
                }
            )
        }
    }
}

final class AlertService {
    
    static let instance = AlertService()
    
    weak var delegate: AlertServiceDelegate?
    
    private init() {
        //Forbidden
    }
    
    static var sharedInstance: AlertService {
        return instance
    }
    
}
