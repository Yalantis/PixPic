//
//  ActivityService.swift
//  P-effect
//
//  Created by Jack Lapin on 04.03.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation
import Parse

typealias FetchingActivitiesCompletion = (activities: [Activity]?, error: NSError?) -> Void

class ActivityService: NSObject {
    
    func fetchFollowers(forUser user: User, completion: FetchingActivitiesCompletion) {
        let query = PFQuery(className: Activity.parseClassName())
        query.whereKey(Constants.ActivityKey.ToUser, equalTo: user)
        query.whereKey(Constants.ActivityKey.Type, equalTo: ActivityType.Follow.rawValue)
        query.findObjectsInBackgroundWithBlock { followActivities, error in
            if let error = error {
                completion(activities: nil, error: error)
            } else if let activities = followActivities as? [Activity] {
                completion(activities: activities, error: nil)
            }
        }
    }
    
    func fetchFollowedBy(forUser user: User, completion: FetchingActivitiesCompletion) {
        let query = PFQuery(className: Activity.parseClassName())
        query.whereKey(Constants.ActivityKey.FromUser, equalTo: user)
        query.whereKey(Constants.ActivityKey.Type, equalTo: ActivityType.Follow.rawValue)
        query.findObjectsInBackgroundWithBlock { followActivities, error in
            if let error = error {
                completion(activities: nil, error: error)
            } else if let activities = followActivities as? [Activity] {
                completion(activities: activities, error: nil)
            }
        }
    }
    
//    func checkIsFollowing() {
//        
//        let isFollowingQuery = PFQuery(className: Activity.parseClassName())
//        isFollowingQuery.whereKey(Constants.ActivityKey.FromUser, equalTo: User.currentUser()!)
//        isFollowingQuery.whereKey(Constants.ActivityKey.Type, equalTo: ActivityType.Follow.rawValue)
//        isFollowingQuery.whereKey(Constants.ActivityKey.ToUser, equalTo: user)
//        isFollowingQuery.countObjectsInBackgroundWithBlock { number, error in
//            print(number)
//            AttributesCache.sharedCache.setFollowStatus((error == nil && number > 0), user: self.user)
//            self.followButton.selected = (error == nil && number > 0)
//        }
//    }
    
    func followUserEventually(user: User, block completionBlock: ((succeeded: Bool, error: NSError?) -> Void)?) {
        if user.objectId == User.currentUser()!.objectId {
            completionBlock!(succeeded: false, error: nil)
            return
        }
        let followActivity = Activity()
        followActivity.type = ActivityType.Follow.rawValue
        followActivity.fromUser = User.currentUser()!
        followActivity.toUser = user
        
        let followACL = PFACL(user: User.currentUser()!)
        followACL.setReadAccess(true, forUser: user)
        followActivity.ACL = followACL
        
        followActivity.saveEventually(completionBlock)
        AttributesCache.sharedCache.setFollowStatus(true, user: user)
    }
    
    func unfollowUserEventually(user: User) {
        let query = PFQuery(className: Activity.parseClassName())
        query.whereKey(Constants.ActivityKey.FromUser, equalTo: User.currentUser()!)
        query.whereKey(Constants.ActivityKey.ToUser, equalTo: user)
        query.whereKey(Constants.ActivityKey.Type, equalTo: ActivityType.Follow.rawValue)
        query.findObjectsInBackgroundWithBlock { followActivities, error in
            if let error = error {
                print(error)
            }
            if let followActivities = followActivities {
                print(followActivities.count)
                for followActivity: PFObject in followActivities as [PFObject]! {
                    followActivity.deleteEventually()
                }
            }
        }
        AttributesCache.sharedCache.setFollowStatus(false, user: user)
    }
    
}
