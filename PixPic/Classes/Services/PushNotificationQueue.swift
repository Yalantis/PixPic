//
//  PushNotificationQueue.swift
//  PixPic
//
//  Created by Jack Lapin on 02.02.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class PushNotificationQueue: NSObject {

    static var notificationQueue = [String]()

    static func handleNotificationQueue() {
        Timer.scheduledTimer(
            timeInterval: 2,
            target: PushNotificationQueue.self,
            selector: #selector(showNotificationFromQueue),
            userInfo: nil,
            repeats: false
        )
    }

    static func addObjectToQueue(_ message: String?) {
        guard let message = message else {
            return
        }
        notificationQueue.append(message)
    }

    static func clearQueue() {
        notificationQueue.removeAll()
    }

    static func showNotificationFromQueue() {
        var message: String?

        switch notificationQueue.count {
        case 0:
            break

        case 1:
             message = notificationQueue.first!

        default:
            message = String(notificationQueue.count) + " new amazing posts!"
        }

        if let message = message {
            AlertManager.sharedInstance.showNotificationAlert(nil, message: message)
        }
    }

}
