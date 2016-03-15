//
//  RemoteNotificationParcer.swift
//  P-effect
//
//  Created by Jack Lapin on 14.03.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

enum RemoteNotificationKey: String {
    case NewPost = "newPost"
    case NewFollower = "newFollower"
}

class RemoteNotificationParcer: NSObject {
    
    static func parce(userInfo: [NSObject: AnyObject]?) -> Dictionary<RemoteNotificationKey, String>? {
        var notificationInfo = [RemoteNotificationKey: String]()
        if let aps = userInfo?["aps"], incomeMessage = aps["alert"] as? String {
            notificationInfo[.NewPost] = incomeMessage
        }
        if let followedUserId = userInfo?["fu"] as? String {
            notificationInfo[.NewFollower] = followedUserId
        }
        return notificationInfo
    }

}
