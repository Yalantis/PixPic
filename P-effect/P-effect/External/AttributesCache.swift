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
    
    func setAttributes(for post: Post, likers: [User], commenters: [User], likedByCurrentUser: Bool) {
        let attributes = [
            Constants.Attributes.IsLikedByCurrentUser: likedByCurrentUser,
            Constants.Attributes.LikesCount: likers.count,
            Constants.Attributes.Likers: likers
        ]
        setAttributes(attributes as! [String : AnyObject], forPost: post)
    }
    
    func setAttributesForUser(user: User, followers: [User]) {
        let attributes = [
            Constants.Attributes.Followers: followers,
            Constants.Attributes.FollowersCount: followers.count
        ]
        setAttributes(attributes as! [String : AnyObject], forUser: user)
    }
    
    func setAttributesForUser(user: User, following: [User]) {
        let attributes = [
            Constants.Attributes.Following: following,
            Constants.Attributes.FollowingCount: following.count
        ]
        setAttributes(attributes as! [String: AnyObject], forUser: user)
    }
    
    func setAttributesForUser(user: User, followersCount: Int, followingCount: Int) {
        let attributes = [
            Constants.Attributes.FollowersCount: followersCount,
            Constants.Attributes.FollowingCount: followingCount
        ]
        setAttributes(attributes, forUser: user)
    }
    
    func attributes(for post: Post) -> [String: AnyObject]? {
        let key = keyForPost(post)
        
        return cache.objectForKey(key) as? [String: AnyObject]
    }
    
    func likesCount(for post: Post) -> Int {
        if let attributes = attributes(for: post) {
            if attributes.isEmpty {
                return 0
            } else if let likesCount = attributes[Constants.Attributes.LikesCount] as? Int {
                return likesCount
            }
        }
        
        return 0
    }
    
    func likers(for post: Post) -> [User] {
        if let attributes = attributes(for: post) {
            if attributes.isEmpty {
                return [User]()
            } else if let likers = attributes[Constants.Attributes.Likers] as? [User] {
                return likers
            }
        }
        
        return [User]()
    }
    
    func setPostIsLikedByCurrentUser(post: Post, liked: Bool) {
        if var attributes = attributes(for: post) {
            attributes[Constants.Attributes.IsLikedByCurrentUser] = liked
            setAttributes(attributes, forPost: post)
        }
    }
    
    func isPostLikedByCurrentUser(post: Post) -> Bool {
        if let attributes = attributes(for: post) {
            if attributes.isEmpty {
                return false
            } else if let isLikedByUser = attributes[Constants.Attributes.IsLikedByCurrentUser] as? Bool {
                return isLikedByUser
            }
        }
        
        return false
    }
    
    func incrementLikersCount(for post: Post) {
        let likerCount = likesCount(for: post) + 1
        if var attributes = attributes(for: post) {
            attributes[Constants.Attributes.LikesCount] = likerCount
            setAttributes(attributes, forPost: post)
        }
    }
    
    func decrementLikersCount(for post: Post) {
        let likersCount = likesCount(for: post) - 1
        if likersCount < 0 {
            return
        }
        if var attributes = attributes(for: post) {
            attributes[Constants.Attributes.LikesCount] = likersCount
            setAttributes(attributes, forPost: post)
        }
    }
    
    func setAttributes(for user: User, postCount count: Int, followedByCurrentUser following: Bool) {
        let attributes = [
            Constants.Attributes.PostsCount: count,
            Constants.Attributes.IsFollowedByCurrentUser: following
        ]
        setAttributes(attributes as! [String : AnyObject], forUser: user)
    }
    
    func attributes(for user: User) -> [String: AnyObject]? {
        let key = keyForUser(user)
        
        return cache.objectForKey(key) as? [String: AnyObject]
    }
    
    func postsCountForUser(user: User) -> Int {
        if let attributes = attributes(for: user),
            postsCount = attributes[Constants.Attributes.PostsCount] as? Int {
                return postsCount
        }
        
        return 0
    }
    
    func followStatus(for user: User) -> Bool? {
        if let attributes = attributes(for: user) {
            let followStatus = attributes[Constants.Attributes.IsFollowedByCurrentUser] as? Bool
            
            return followStatus
        }
        
        return nil
    }
    
    func setPostCount(count: Int,  user: User) {
        if var attributes = attributes(for: user) {
            attributes[Constants.Attributes.PostsCount] = count
            setAttributes(attributes, forUser: user)
        }
    }
    
    func setFollowStatus(following: Bool, user: User) {
        if var attributes = attributes(for: user) {
            attributes[Constants.Attributes.IsFollowedByCurrentUser] = following
            setAttributes(attributes, forUser: user)
        }
    }
    
    // MARK: - Private methods
    private func setAttributes(attributes: [String: AnyObject], forPost post: Post) {
        let key = keyForPost(post)
        cache.setObject(attributes, forKey: key)
    }
    
    private func setAttributes(attributes: [String: AnyObject], forUser user: User) {
        let key = keyForUser(user)
        cache.setObject(attributes, forKey: key)
    }
    
    private func keyForPost(post: Post) -> String {
        return "post_\(post.objectId)"
    }
    
    private func keyForUser(user: User) -> String {
        return "user_\(user.objectId)"
    }
}
