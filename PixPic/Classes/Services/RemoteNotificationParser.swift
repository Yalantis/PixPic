//
//  RemoteNotificationHelper.swift
//  PixPic
//
//  Created by Jack Lapin on 14.03.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

enum RemoteNotificationObject {

    case NewPost(message: String, postId: String)
    case NewFollower(message: String, followerId: String)
    case NewLikedPost(message: String, likedPostId: String)

}

final class RemoteNotificationParser {

    static func parse(userInfo: [NSObject: AnyObject]?) -> RemoteNotificationObject? {
        guard let type = userInfo?["t"] as? String,
            aps = userInfo?["aps"] as? [String: AnyObject],
            message = aps["alert"] as? String else {
                return nil
        }

        switch type {
        case "p":
            if let postId = userInfo?["postid"] as? String {
                return RemoteNotificationObject.NewPost(message: message, postId: postId)
            }

        case "f":
            if let followerId = userInfo?["fromUserId"] as? String {
                return RemoteNotificationObject.NewFollower(message: message, followerId: followerId)
            }

        case "l":
            if let likedPostId = userInfo?["pid"] as? String {
                return RemoteNotificationObject.NewLikedPost(message: message, likedPostId: likedPostId)
            }

        default:
            break
        }
        return nil
    }

}
