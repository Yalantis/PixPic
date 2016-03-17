//
//  RemoteNotificationHelper.swift
//  P-effect
//
//  Created by Jack Lapin on 14.03.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

enum RemoteNotificationObject {
    
    case NewPost(message: String, postId: String)
    case NewFollower(message: String, followerId: String)
    case None
    
}

final class RemoteNotificationHelper {
    
    static func parse(userInfo: [NSObject: AnyObject]?) -> RemoteNotificationObject {
        var result = RemoteNotificationObject.None
        guard let type = userInfo?["t"] as? String,
            aps = userInfo?["aps"],
            message = aps["alert"] as? String else {
                return result
        }
        switch type {
        case "p":
            if let postId = userInfo?["postid"] as? String {
                result = RemoteNotificationObject.NewPost(message: message, postId: postId)
            }
            return result
            
        case "f":
            if let followerId = userInfo?["fromUserId"] as? String {
                result = RemoteNotificationObject.NewFollower(message: message, followerId: followerId)
            }
            return result
            
        default:
            return result
        }
    }
    
}


