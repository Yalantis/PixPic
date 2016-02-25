//
//  AlertService.swift
//  P-effect
//
//  Created by Jack Lapin on 17.01.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import Toast

private let notification = "Notification"

protocol AlertServiceDelegate: class {
    
    func showSimpleAlert(message: String)
    func showNotificationAlert(userInfo: [NSObject : AnyObject]?, message: String?)
    
}

extension AlertServiceDelegate where Self: FeedPresenter {
    
    func showSimpleAlert(message: String) {
        currentViewController.view.makeToast(message, duration: 2.0, position: CSToastPositionBottom)
    }
    
    func showNotificationAlert(userInfo: [NSObject : AnyObject]?, var message: String?) {
        let title = notification
        
        if let aps = userInfo?["aps"] as? [String: String] {
            message = aps["alert"]
        }
        
        let isControllerWaitingForResponse = (currentViewController.presentedViewController as? UIAlertController) != nil
        
        if isControllerWaitingForResponse {
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
    
    private weak var delegate: AlertServiceDelegate?
    
    private init() {
    }
    
    static var sharedInstance: AlertService {
        return instance
    }
    
    func registerAlertListener(listener: AlertServiceDelegate) {
        delegate = listener
    }
    
    func showSimpleAlert(message: String) {
        delegate?.showSimpleAlert(message)
    }
    
    func showNotificationAlert(userInfo: [NSObject : AnyObject]?, message: String?) {
        delegate?.showNotificationAlert(userInfo, message: message)
    }
    
}
