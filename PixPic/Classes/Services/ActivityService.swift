//
//  ActivityService.swift
//  PixPic
//
//  Created by Jack Lapin on 04.03.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation
import Parse

typealias FetchingFollowersCompletion = ((followers: [User]?, error: NSError?) -> Void)?

class ActivityService {
    
    func fetchFollowers(type: FollowType, forUser user: User, completion: FetchingFollowersCompletion) {
        let isFollowers = (type == .Followers)
        let key = isFollowers ? Constants.ActivityKey.ToUser : Constants.ActivityKey.FromUser
        
        let query = PFQuery(className: Activity.parseClassName())
        query.whereKey(key, equalTo: user)
        query.whereKey(Constants.ActivityKey.Type, equalTo: ActivityType.Follow.rawValue)
        
        query.findObjectsInBackgroundWithBlock { followActivities, error in
            if let error = error {
                completion?(followers: nil, error: error)
            } else if let activities = followActivities as? [Activity] {
                var followers = isFollowers ? activities.map{$0.fromUser} : activities.map{$0.toUser}
                let followerQuery = User.sortedQuery
                var followersIds = [String]()
                for follower in followers {
                    if let followerId = follower.objectId {
                        followersIds.append(followerId)
                    }
                }
                followerQuery.whereKey(Constants.UserKey.Id, containedIn: followersIds)
                
                followerQuery.findObjectsInBackgroundWithBlock { objects, error in
                    if let objects = objects as? [User] {
                        followers = objects
                        let realFollowers = Set(followers)
                        followers = Array(realFollowers)
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
    
    func fetchFollowersQuantity(user: User, completion: ((followersCount: Int, followingCount: Int) -> Void)?) {
        var followersCount = 0
        var followingCount = 0
        fetchFollowers(.Followers, forUser: user) { [weak self] activities, error -> Void in
            if let activities = activities {
                followersCount = activities.count
                self?.fetchFollowers(.Following, forUser: user) { activities, error -> Void in
                    if let activities = activities {
                        followingCount = activities.count
                        completion?(followersCount: followersCount, followingCount: followingCount)
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
    
    func checkFollowingStatus(user: User, completion: FollowStatus -> Void) {
        let isFollowingQuery = PFQuery(className: Activity.parseClassName())
        isFollowingQuery.whereKey(Constants.ActivityKey.FromUser, equalTo: User.currentUser()!)
        isFollowingQuery.whereKey(Constants.ActivityKey.Type, equalTo: ActivityType.Follow.rawValue)
        isFollowingQuery.whereKey(Constants.ActivityKey.ToUser, equalTo: user)
        isFollowingQuery.countObjectsInBackgroundWithBlock { count, error in
            let status: FollowStatus = (error == nil && count > 0) ? .Following : .NotFollowing
            AttributesCache.sharedCache.setFollowStatus(status, user: user)
            completion(status)
        }
    }
    
    func followUserEventually(user: User, block completionBlock: ((succeeded: Bool, error: NSError?) -> Void)?) {
        guard let currentUser = User.currentUser() else {
            let userError = NSError.authenticationError(.ParseCurrentUserNotExist)
            completionBlock?(succeeded: false, error: userError)
            
            return
        }
        if user.objectId == currentUser.objectId {
            completionBlock?(succeeded: false, error: nil)
            
            return
        }
        let followActivity = Activity()
        followActivity.type = ActivityType.Follow.rawValue
        followActivity.fromUser = currentUser
        followActivity.toUser = user
        followActivity.saveInBackgroundWithBlock(completionBlock)
        AttributesCache.sharedCache.setFollowStatus(.Following, user: user)
    }
    
    func unfollowUserEventually(user: User, block completionBlock: ((succeeded: Bool, error: NSError?) -> Void)?) {
        guard let currentUser = User.currentUser() else {
            let userError = NSError.authenticationError(.ParseCurrentUserNotExist)
            completionBlock?(succeeded: false, error: userError)
            
            return
        }
        let query = PFQuery(className: Activity.parseClassName())
        query.whereKey(Constants.ActivityKey.FromUser, equalTo: currentUser)
        query.whereKey(Constants.ActivityKey.ToUser, equalTo: user)
        query.whereKey(Constants.ActivityKey.Type, equalTo: ActivityType.Follow.rawValue)
        query.findObjectsInBackgroundWithBlock { followActivities, error in
            if let error = error {
                completionBlock?(succeeded: false, error: error)
            } else if let followActivities = followActivities {
                for followActivity in followActivities {
                    followActivity.deleteInBackgroundWithBlock(completionBlock)
                }
            }
        }
        AttributesCache.sharedCache.setFollowStatus(.NotFollowing, user: user)
    }
    
}
