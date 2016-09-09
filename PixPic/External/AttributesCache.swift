//
//  AttributesCache.swift
//  PixPic
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

    func setAttributes(for post: Post, likers: [User]? = nil, commentes: [User]? = nil, likeStatusByCurrentUser: LikeStatus? = nil) {
        var attributes = [String: AnyObject]()

        if let likers = likers {
            attributes[Constants.Attributes.likers] = likers
            attributes[Constants.Attributes.likesCount] = likers.count
        }

        if let commentes = commentes {
            attributes[Constants.Attributes.comments] = commentes
        }

        if let likeStatusByCurrentUser = likeStatusByCurrentUser {
            attributes[Constants.Attributes.likeStatusByCurrentUser] = likeStatusByCurrentUser.rawValue
        }

        setAttributes(attributes, forPost: post)
    }

    func setAttributesForUser(user: User, followers: [User]) {
        let attributes = [
            Constants.Attributes.followers: followers,
            Constants.Attributes.followersCount: followers.count
        ]
        setAttributes(attributes as! [String : AnyObject], forUser: user)
    }

    func setAttributesForUser(user: User, following: [User]) {
        let attributes = [
            Constants.Attributes.following: following,
            Constants.Attributes.followingCount: following.count
        ]
        setAttributes(attributes as! [String: AnyObject], forUser: user)
    }

    func setAttributesForUser(user: User, followersCount: Int, followingCount: Int) {
        let attributes = [
            Constants.Attributes.followersCount: followersCount,
            Constants.Attributes.followingCount: followingCount
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
            } else if let likesCount = attributes[Constants.Attributes.likesCount] as? Int {
                return likesCount
            }
        }

        return 0
    }

    func likers(for post: Post) -> [User] {
        if let attributes = attributes(for: post), likers = attributes[Constants.Attributes.likers] as? [User] {
            return likers
        }

        return [User]()
    }

    func setLikeStatusByCurrentUser(post: Post, likeStatus: LikeStatus) {
        if var attributes = attributes(for: post) {
            attributes[Constants.Attributes.likeStatusByCurrentUser] = likeStatus.rawValue
            setAttributes(attributes, forPost: post)
        }
    }

    func postLikeStatusByCurrentUser(post: Post) -> LikeStatus {
        if let attributes = attributes(for: post), likeStatus =
            LikeStatus(rawValue: attributes[Constants.Attributes.likeStatusByCurrentUser] as! Int) {
            return likeStatus
        }

        return LikeStatus.Unknown
    }

    func incrementLikersCount(for post: Post) {
        let likerCount = likesCount(for: post) + 1
        if var attributes = attributes(for: post) {
            attributes[Constants.Attributes.likesCount] = likerCount
            setAttributes(attributes, forPost: post)
        }
    }

    func decrementLikersCount(for post: Post) {
        let likersCount = likesCount(for: post) - 1
        if likersCount < 0 {
            return
        }
        if var attributes = attributes(for: post) {
            attributes[Constants.Attributes.likesCount] = likersCount
            setAttributes(attributes, forPost: post)
        }
    }

    func setAttributes(for user: User, postCount count: Int, followedByCurrentUser followStatus: FollowStatus) {
        let attributes: [String: AnyObject] = [
            Constants.Attributes.postsCount: count,
            Constants.Attributes.followStatusByCurrentUser: followStatus.rawValue
        ]
        setAttributes(attributes, forUser: user)
    }

    func attributes(for user: User) -> [String: AnyObject]? {
        let key = keyForUser(user)

        return cache.objectForKey(key) as? [String: AnyObject]
    }

    func postsCountForUser(user: User) -> Int {
        if let attributes = attributes(for: user),
            postsCount = attributes[Constants.Attributes.postsCount] as? Int {

            return postsCount
        }

        return 0
    }

    func followStatus(for user: User) -> FollowStatus? {
        if let attributes = attributes(for: user), followStatus =
            attributes[Constants.Attributes.followStatusByCurrentUser] {
            return FollowStatus(rawValue: followStatus as! Int)
        }

        return FollowStatus.Unknown
    }

    func setPostCount(count: Int, user: User) {
        if var attributes = attributes(for: user) {
            attributes[Constants.Attributes.postsCount] = count
            setAttributes(attributes, forUser: user)
        }
    }

    func setFollowStatus(followStatus: FollowStatus, user: User) {
        if var attributes = attributes(for: user) {
            attributes[Constants.Attributes.followStatusByCurrentUser] = followStatus.rawValue
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
