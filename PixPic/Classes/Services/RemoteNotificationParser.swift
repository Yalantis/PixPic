//
//  RemoteNotificationHelper.swift
//  PixPic
//
//  Created by Jack Lapin on 14.03.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

enum RemoteNotificationObject {

    case newPost(message: String, postId: String)
    case newFollower(message: String, followerId: String)
    case newLikedPost(message: String, likedPostId: String)

}

final class RemoteNotificationParser {

    static func parse(_ userInfo: [AnyHashable: Any]?) -> RemoteNotificationObject? {
        guard let type = userInfo?["t"] as? String,
            let aps = userInfo?["aps"] as? [String: AnyObject],
            let message = aps["alert"] as? String else {
                return nil
        }

        switch type {
        case "p":
            if let postId = userInfo?["postid"] as? String {
                return RemoteNotificationObject.newPost(message: message, postId: postId)
            }

        case "f":
            if let followerId = userInfo?["fromUserId"] as? String {
                return RemoteNotificationObject.newFollower(message: message, followerId: followerId)
            }

        case "l":
            if let likedPostId = userInfo?["pid"] as? String {
                return RemoteNotificationObject.newLikedPost(message: message, likedPostId: likedPostId)
            }

        default:
            break
        }
        return nil
    }

}
