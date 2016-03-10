//
//  AttributesCache.swift
//  P-effect
//
//  Created by Jack Lapin on 07.03.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

final class AttributesCache {
    private var cache: NSCache
    
    // MARK:- Initialization
    
    static let sharedCache = AttributesCache()
    
    private init() {
        self.cache = NSCache()
    }
    
    func clear() {
        cache.removeAllObjects()
    }
    
    func setAttributesForPost(post: Post, likers: [User], commenters: [User], likedByCurrentUser: Bool) {
        let attributes = [
            Constants.Attributes.IsLikedByCurrentUser: likedByCurrentUser,
            Constants.Attributes.LikeCount: likers.count,
            Constants.Attributes.Likers: likers,
        ]
        setAttributes(attributes as! [String : AnyObject], forPost: post)
    }
    
    func setAttributesForUser(user: User, followers: [User], followedBy: [User]) {
        let attributes = [
            Constants.Attributes.Followers: followers,
            Constants.Attributes.FollowedBy: followedBy,
        ]
       // setAttributes(attributes as! [String : AnyObject], forUser: user)
    }
    
    func attributesForPost(post: Post) -> [String:AnyObject]? {
        let key: String = self.keyForPost(post)
        return cache.objectForKey(key) as? [String:AnyObject]
    }
    
    func likeCountForPost(post: Post) -> Int {
        let attributes: [NSObject:AnyObject]? = self.attributesForPost(post)
        if attributes != nil {
            return attributes![Constants.Attributes.LikeCount] as! Int
        }
        return 0
    }
    
    func likersForPost(post: Post) -> [User] {
        let attributes = attributesForPost(post)
        if attributes != nil {
            return attributes![Constants.Attributes.Likers] as! [User]
        }
        return [User]()
    }
    
    func setPostIsLikedByCurrentUser(post: Post, liked: Bool) {
        var attributes = attributesForPost(post)
        attributes![Constants.Attributes.IsLikedByCurrentUser] = liked
        setAttributes(attributes!, forPost: post)
    }
    
    func isPostLikedByCurrentUser(post: Post) -> Bool {
        let attributes = attributesForPost(post)
        if attributes != nil {
            return attributes![Constants.Attributes.IsLikedByCurrentUser] as! Bool
        }
        return false
    }
    
    func incrementLikerCountForpost(post: Post) {
        let likerCount = likeCountForPost(post) + 1
        var attributes = attributesForPost(post)
        attributes![Constants.Attributes.LikeCount] = likerCount
        setAttributes(attributes!, forPost: post)
    }
    
    func decrementLikerCountForpost(post: Post) {
        let likerCount = likeCountForPost(post) - 1
        if likerCount < 0 {
            return
        }
        var attributes = attributesForPost(post)
        attributes![Constants.Attributes.LikeCount] = likerCount
        setAttributes(attributes!, forPost: post)
    }
    
    func setAttributesForUser(user: User, postCount count: Int, followedByCurrentUser following: Bool) {
        let attributes = [
            Constants.Attributes.PostsCount: count,
            Constants.Attributes.IsFollowedByCurrentUser: following
        ]
        setAttributes(attributes as! [String : AnyObject], forUser: user)
    }
    
    func attributesForUser(user: User) -> [String:AnyObject]? {
        let key = keyForUser(user)
        return cache.objectForKey(key) as? [String:AnyObject]
    }
    
    func postCountForUser(user: User) -> Int {
        if let attributes = attributesForUser(user),
            postCount = attributes[Constants.Attributes.PostsCount] as? Int {
                return postCount
        }
        return 0
    }
    
    func followStatusForUser(user: User) -> Bool {
        if let attributes = attributesForUser(user),
            followStatus = attributes[Constants.Attributes.IsFollowedByCurrentUser] as? Bool {
                return followStatus
        }
        return false
    }
    
    func setPostCount(count: Int,  user: User) {
        if var attributes = attributesForUser(user) {
            attributes[Constants.Attributes.PostsCount] = count
            setAttributes(attributes, forUser: user)
        }
    }
    
    func setFollowStatus(following: Bool, user: User) {
        if var attributes = attributesForUser(user) {
            attributes[Constants.Attributes.IsFollowedByCurrentUser] = following
            setAttributes(attributes, forUser: user)
        }
    }
    
    // MARK:- private methods
    
   private func setAttributes(attributes: [String:AnyObject], forPost post: Post) {
        let key: String = self.keyForPost(post)
        cache.setObject(attributes, forKey: key)
    }
    
    private func setAttributes(attributes: [String:AnyObject], forUser user: User) {
        let key: String = self.keyForUser(user)
        cache.setObject(attributes, forKey: key)
    }
    
    private func keyForPost(post: Post) -> String {
        return "post_\(post.objectId)"
    }
    
    private func keyForUser(user: User) -> String {
        return "user_\(user.objectId)"
    }
}
