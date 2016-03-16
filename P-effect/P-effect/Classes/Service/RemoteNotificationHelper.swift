//
//  RemoteNotificationHelper.swift
//  P-effect
//
//  Created by Jack Lapin on 14.03.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

struct RemoteNotificationContent {
    
    internal private(set) var message: String = "No message"
    internal private(set) var postId: String?
    internal private(set) var followerId: String?
    
}

final class RemoteNotificationHelper {
    
    static func parse(userInfo: [NSObject: AnyObject]?) -> RemoteNotificationContent? {
        guard let type = userInfo?["t"] as? String,
            aps = userInfo?["aps"],
            message = aps["alert"] as? String else {
                return nil
        }
        var result = RemoteNotificationContent()
        result.message = message
        
        switch type {
        case "p":
            if let postId = userInfo?["postid"] as? String {
                result.postId = postId
            }
            return result
            
        case "f":
            if let followerId = userInfo?["fromUserId"] as? String {
                result.followerId = followerId
            }
            return result
            
        default:
            return result
        }
    }

}
