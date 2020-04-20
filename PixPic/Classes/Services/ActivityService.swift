//
//  ActivityService.swift
//  PixPic
//
//  Created by Jack Lapin on 04.03.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation
import Parse

typealias FetchingFollowersCompletion = ((_ followers: [User]?, _ error: NSError?) -> Void)?
typealias FetchingLikesCompletion = ((_ likers: [User]?, _ error: NSError?) -> Void)?

class ActivityService {

    func fetchFollowers(_ type: FollowType, forUser user: User, completion: FetchingFollowersCompletion) {
        let isFollowers = (type == .Followers)
        let key = isFollowers ? Constants.ActivityKey.toUser : Constants.ActivityKey.fromUser

        let query = PFQuery(className: Activity.parseClassName())
        query.whereKey(key, equalTo: user)
        query.whereKey(Constants.ActivityKey.type, equalTo: ActivityType.Follow.rawValue)
        query.cachePolicy = .CacheThenNetwork
        query.findObjectsInBackgroundWithBlock { followActivities, error in
            if let error = error {
                completion?(followers: nil, error: error)
            } else if let activities = followActivities as? [Activity] {
                let followers = isFollowers ? activities.map { $0.fromUser } : activities.map { $0.toUser }
                let followerQuery = User.sortedQuery
                var followersIds = [String]()
                for follower in followers {
                    if let followerId = follower.objectId {
                        followersIds.append(followerId)
                    }
                }
                followerQuery.whereKey(Constants.UserKey.id, containedIn: followersIds)

                followerQuery.findObjectsInBackgroundWithBlock { objects, error in
                    if let followers = objects as? [User] {
                        if isFollowers {
                            AttributesCache.sharedCache.setAttributesForUser(user, followers: followers)
                        } else {
                            AttributesCache.sharedCache.setAttributesForUser(user, following: followers)
                        }
                        completion?(followers: followers, error: nil)
                    } else if let error = error {
                        completion?(followers: nil, error: error)
                    }
                }
            }
        }
    }

    func fetchFollowersQuantity(_ user: User, completion: ((_ followersCount: Int, _ followingCount: Int) -> Void)?) {
        var followersCount = 0
        var followingCount = 0
        fetchFollowers(.Followers, forUser: user) { [weak self] activities, error -> Void in
            if let activities = activities {
                followersCount = activities.count
                self?.fetchFollowers(.Following, forUser: user) { activities, error -> Void in
                    if let activities = activities {
                        followingCount = activities.count
                        completion?(followersCount, followingCount)
                        AttributesCache.sharedCache.setAttributesForUser(
                            user,
                            followersCount: followersCount,
                            followingCount: followingCount
                        )
                    }
                }
            }
        }
    }

    func checkFollowingStatus(_ user: User, completion: @escaping (FollowStatus) -> Void) {
        let isFollowingQuery = PFQuery(className: Activity.parseClassName())
        isFollowingQuery.whereKey(Constants.ActivityKey.fromUser, equalTo: User.currentUser()!)
        isFollowingQuery.whereKey(Constants.ActivityKey.type, equalTo: ActivityType.Follow.rawValue)
        isFollowingQuery.whereKey(Constants.ActivityKey.toUser, equalTo: user)
        isFollowingQuery.countObjectsInBackgroundWithBlock { count, error in
            let status: FollowStatus = (error == nil && count > 0) ? .Following : .NotFollowing
            AttributesCache.sharedCache.setFollowStatus(status, user: user)
            completion(status)
        }
    }

    func followUserEventually(_ user: User, block completionBlock: ((_ succeeded: Bool, _ error: NSError?) -> Void)?) {
        guard let currentUser = User.currentUser() else {
            let userError = NSError.authenticationError(.ParseCurrentUserNotExist)
            completionBlock?(succeeded: false, error: userError)

            return
        }
        if user.objectId == currentUser.objectId {
            completionBlock?(false, nil)

            return
        }
        let followActivity = Activity()
        followActivity.type = ActivityType.Follow.rawValue
        followActivity.fromUser = currentUser
        followActivity.toUser = user
        followActivity.saveInBackgroundWithBlock(completionBlock)
        AttributesCache.sharedCache.setFollowStatus(.following, user: user)
    }

    func unfollowUserEventually(_ user: User, block completionBlock: ((_ succeeded: Bool, _ error: NSError?) -> Void)?) {
        guard let currentUser = User.currentUser() else {
            let userError = NSError.authenticationError(.ParseCurrentUserNotExist)
            completionBlock?(succeeded: false, error: userError)

            return
        }
        let query = PFQuery(className: Activity.parseClassName())
        query.whereKey(Constants.ActivityKey.fromUser, equalTo: currentUser)
        query.whereKey(Constants.ActivityKey.toUser, equalTo: user)
        query.whereKey(Constants.ActivityKey.type, equalTo: ActivityType.Follow.rawValue)
        query.cachePolicy = .CacheThenNetwork
        query.findObjectsInBackgroundWithBlock { followActivities, error in
            if let error = error {
                completionBlock?(succeeded: false, error: error)
            } else if let followActivities = followActivities {
                for followActivity in followActivities {
                    followActivity.deleteInBackgroundWithBlock(completionBlock)
                }
            }
        }
        AttributesCache.sharedCache.setFollowStatus(.notFollowing, user: user)
    }

    func likePostEventually(_ post: Post, block completionBlock: ((_ succeeded: Bool, _ error: NSError?) -> Void)?) {
        guard let currentUser = User.currentUser() else {
            let userError = NSError.authenticationError(.ParseCurrentUserNotExist)
            completionBlock?(succeeded: false, error: userError)

            return
        }
        let likeActivity = Activity()
        likeActivity.type = ActivityType.Like.rawValue
        likeActivity.fromUser = currentUser
        likeActivity.toPost = post
        likeActivity.saveInBackgroundWithBlock(completionBlock)
        AttributesCache.sharedCache.setLikeStatusByCurrentUser(post, likeStatus: .liked)
    }

    func unlikePostEventually(_ post: Post, block completionBlock: ((_ succeeded: Bool, _ error: NSError?) -> Void)?) {
        guard let currentUser = User.currentUser() else {
            let userError = NSError.authenticationError(.ParseCurrentUserNotExist)
            completionBlock?(succeeded: false, error: userError)

            return
        }
        let query = PFQuery(className: Activity.parseClassName())
        query.whereKey(Constants.ActivityKey.fromUser, equalTo: currentUser)
        query.whereKey(Constants.ActivityKey.toPost, equalTo: post)
        query.whereKey(Constants.ActivityKey.type, equalTo: ActivityType.Like.rawValue)
        query.cachePolicy = .CacheThenNetwork
        query.findObjectsInBackgroundWithBlock { likeActivities, error in
            if let error = error {
                completionBlock?(succeeded: false, error: error)
            } else if let likeActivities = likeActivities {
                for likeActivity in likeActivities {
                    likeActivity.deleteInBackgroundWithBlock(completionBlock)
                }
            }
        }
        AttributesCache.sharedCache.setLikeStatusByCurrentUser(post, likeStatus: .notLiked)
    }

    func fetchLikers(_ post: Post, completion: FetchingLikesCompletion) {
        let key = Constants.ActivityKey.toPost
        let query = PFQuery(className: Activity.parseClassName())
        query.cachePolicy = .CacheThenNetwork
        query.whereKey(key, equalTo: post)
        query.whereKey(Constants.ActivityKey.type, equalTo: ActivityType.Like.rawValue)

        query.findObjectsInBackgroundWithBlock { likeActivities, error in
            if let error = error {
                completion?(likers: nil, error: error)
            } else if let activities = likeActivities as? [Activity] {

                let likers = activities.map { $0.fromUser }
                AttributesCache.sharedCache.setAttributes(for: post, likers: likers)
                completion?(likers: likers, error: nil)
            }
        }
    }

    func fetchLikesQuantity(_ post: Post, completion: ((Int) -> Void)?) {
        fetchLikers(post) { likers, error in
            if let likers = likers {
                let likersCount = likers.count
                completion?(likersCount)
                AttributesCache.sharedCache.setAttributes(for: post, likers: likers, likeStatusByCurrentUser: .liked)
            }
        }
    }

    func fetchLikeStatus(_ post: Post, completion: @escaping (LikeStatus) -> Void) {
        let islikedQuery = PFQuery(className: Activity.parseClassName())
        islikedQuery.cachePolicy = .CacheThenNetwork
        islikedQuery.whereKey(Constants.ActivityKey.fromUser, equalTo: User.currentUser()!)
        islikedQuery.whereKey(Constants.ActivityKey.type, equalTo: ActivityType.Like.rawValue)
        islikedQuery.whereKey(Constants.ActivityKey.toPost, equalTo: post)
        islikedQuery.getFirstObjectInBackgroundWithBlock { likeActivity, error in
            if likeActivity != nil {
                AttributesCache.sharedCache.setAttributes(for: post, likeStatusByCurrentUser: .Liked)
                completion(.Liked)
            } else {
                AttributesCache.sharedCache.setAttributes(for: post, likeStatusByCurrentUser: .NotLiked)
                completion(.NotLiked)
            }
        }
    }

}
