//
//  ActivityService.swift
//  P-effect
//
//  Created by Jack Lapin on 04.03.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation
import Parse

typealias FetchingFollowersCompletion = (followers: [User]?, error: NSError?) -> Void

class ActivityService: NSObject {
    
    func fetchFollowers(forUser user: User, completion: FetchingFollowersCompletion) {
        var followers = [User]()
        let query = PFQuery(className: Activity.parseClassName())
        query.whereKey(Constants.ActivityKey.ToUser, equalTo: user)
        query.whereKey(Constants.ActivityKey.Type, equalTo: ActivityType.Follow.rawValue)
        
        query.findObjectsInBackgroundWithBlock { followActivities, error in
            if let error = error {
                completion(followers: nil, error: error)
            } else if let activities = followActivities as? [Activity] {
                followers = activities.map({$0.fromUser})
                let userQuery = User.sortedQuery()
                var userIds = [String]()
                for user in followers {
                    if let userId = user.objectId {
                        userIds.append(userId)
                    }
                }
                userQuery.whereKey(Constants.UserKey.Id, containedIn: userIds)
                userQuery.findObjectsInBackgroundWithBlock { objects, error in
                    
                    if let objects = objects as? [User] {
                        followers = objects
                    }
                    let realFollowers = Set(followers)
                    let followers = Array(realFollowers)
                    AttributesCache.sharedCache.setAttributesForUser(user, followers: followers)
                    completion(followers: followers, error: nil)
                }
            }
        }
    }
    
    func fetchFollowing(forUser user: User, completion: FetchingFollowersCompletion) {
        var following = [User]()
        let query = PFQuery(className: Activity.parseClassName())
        query.whereKey(Constants.ActivityKey.FromUser, equalTo: user)
        query.whereKey(Constants.ActivityKey.Type, equalTo: ActivityType.Follow.rawValue)
        
        query.findObjectsInBackgroundWithBlock { followActivities, error in
            if let error = error {
                completion(followers: nil, error: error)
            } else if let activities = followActivities as? [Activity] {
                following = activities.map({$0.toUser})
                let userQuery = User.sortedQuery()
                var userIds = [String]()
                for user in following {
                    if let userId = user.objectId {
                        userIds.append(userId)
                    }
                }
                userQuery.whereKey(Constants.UserKey.Id, containedIn: userIds)
                
                userQuery.findObjectsInBackgroundWithBlock { objects, error in
                    if let objects = objects as? [User] {
                        following = objects
                    }
                    let realFollowing = Set(following)
                    following = Array(realFollowing)
                    AttributesCache.sharedCache.setAttributesForUser(user, following: following)
                    completion(followers: following, error: nil)
                }
            }
        }
    }
    
    func fetchFollowersQuantity(user: User, completion:(followersCount: Int, followingCount: Int) -> Void) {
        var followersCount = 0
        var followingCount = 0
        fetchFollowers(forUser: user) { [weak self] activities, error -> Void in
            if let activities = activities {
                followersCount = activities.count
                self?.fetchFollowing(forUser: user) { activities, error -> Void in
                    if let activities = activities {
                        followingCount = activities.count
                        completion(followersCount: followersCount, followingCount: followingCount)
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
    
    func checkIsFollowing(user: User, completion: (Bool) -> Void) {
        let isFollowingQuery = PFQuery(className: Activity.parseClassName())
        isFollowingQuery.whereKey(Constants.ActivityKey.FromUser, equalTo: User.currentUser()!)
        isFollowingQuery.whereKey(Constants.ActivityKey.Type, equalTo: ActivityType.Follow.rawValue)
        isFollowingQuery.whereKey(Constants.ActivityKey.ToUser, equalTo: user)
        isFollowingQuery.countObjectsInBackgroundWithBlock { number, error in
            AttributesCache.sharedCache.setFollowStatus((error == nil && number > 0), user: user)
            completion(error == nil && number > 0)
        }
    }
    
    func followUserEventually(user: User, block completionBlock: ((succeeded: Bool, error: NSError?) -> Void)?) {
        guard let currentUser = User.currentUser() else {
            completionBlock?(succeeded: false, error: nil)
            return
        }
        if user.objectId == currentUser {
            completionBlock?(succeeded: false, error: nil)
            return
        }
        let followActivity = Activity()
        followActivity.type = ActivityType.Follow.rawValue
        followActivity.fromUser = currentUser
        followActivity.toUser = user
        followActivity.saveEventually(completionBlock)
        AttributesCache.sharedCache.setFollowStatus(true, user: user)
    }
    
    func unfollowUserEventually(user: User, block completionBlock: ((succeeded: Bool, error: NSError?) -> Void)?) {
        guard let currentUser = User.currentUser() else {
            return
        }
        let query = PFQuery(className: Activity.parseClassName())
        query.whereKey(Constants.ActivityKey.FromUser, equalTo: currentUser)
        query.whereKey(Constants.ActivityKey.ToUser, equalTo: user)
        query.whereKey(Constants.ActivityKey.Type, equalTo: ActivityType.Follow.rawValue)
        query.findObjectsInBackgroundWithBlock { followActivities, error in
            if let error = error {
                print(error)
            } else if let followActivities = followActivities {
                for followActivity in followActivities {
                    followActivity.deleteInBackgroundWithBlock(completionBlock)
                }
            }
        }
        AttributesCache.sharedCache.setFollowStatus(false, user: user)
    }
    
}
