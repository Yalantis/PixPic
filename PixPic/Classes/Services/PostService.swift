//
//  PostService.swift
//  PixPic
//
//  Created by Jack Lapin on 16.02.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

private let messageUploadSuccessful = NSLocalizedString("upload_successful", comment: "")

typealias LoadingPostsCompletion = (_ posts: [Post]?, _ error: NSError?) -> Void

class PostService {

    // MARK: - Public methods
    func loadPosts(_ user: User? = nil, completion: LoadingPostsCompletion) {
        let query = Post.sortedQuery
        query.cachePolicy = .NetworkElseCache
        query.limit = Constants.DataSource.queryLimit
        loadPosts(user, query: query, completion: completion)
    }

    func loadPagedPosts(_ user: User? = nil, offset: Int = 0, completion: LoadingPostsCompletion) {
        let query = Post.sortedQuery
        query.cachePolicy = .NetworkElseCache
        query.limit = Constants.DataSource.queryLimit
        query.skip = offset
        loadPosts(user, query: query, completion: completion)
    }

    func savePost(_ image: PFFile, comment: String? = nil) {
        image.saveInBackgroundWithBlock({ succeeded, error in
            if succeeded {
                log.debug("Saved!")
                self.uploadPost(image, comment: comment)
            } else if let error = error {
                log.debug(error.localizedDescription)
            }
            }, progressBlock: { progress in
                log.debug("Uploaded: \(progress)%")
        })
    }

    func removePost(_ post: Post, completion: (Bool, NSError?) -> Void) {
        post.deleteInBackgroundWithBlock(completion)
    }

    // MARK: - Private methods
    fileprivate func uploadPost(_ image: PFFile, comment: String?) {
        guard let user = User.currentUser() else {
            // Authentication service
            return
        }
        let post = Post(image: image, user: user, comment: comment)
        post.saveInBackgroundWithBlock { succeeded, error in
            if succeeded {
                AlertManager.sharedInstance.showSimpleAlert(messageUploadSuccessful)
                NSNotificationCenter.defaultCenter().postNotificationName(
                    Constants.NotificationName.newPostIsUploaded,
                    object: nil
                )
            } else {
                if let error = error?.localizedDescription {
                    log.debug(error)
                }
            }
        }
    }

    fileprivate func loadPosts(_ user: User?, query: PFQuery, completion: @escaping LoadingPostsCompletion) {
        if User.isAbsent {
            log.debug("No user signUP")
            fetchPosts(query, completion: completion)

            return
        }
        query.cachePolicy = .NetworkElseCache

        if let user = user {
            query.whereKey("user", equalTo: user)
            fetchPosts(query, completion: completion)

        } else if SettingsHelper.isShownOnlyFollowingUsersPosts && !User.notAuthorized {
            let followersQuery = PFQuery(className: Activity.parseClassName())
            followersQuery.cachePolicy = .CacheThenNetwork
            followersQuery.whereKey(Constants.ActivityKey.fromUser, equalTo: User.currentUser()!)
            followersQuery.whereKey(Constants.ActivityKey.type, equalTo: ActivityType.Follow.rawValue)
            followersQuery.includeKey(Constants.ActivityKey.toUser)

            var arrayOfFollowers: [User] = [User.currentUser()!]
            followersQuery.findObjectsInBackgroundWithBlock { [weak self] activities, error in
                if let error = error {
                    log.debug(error.localizedDescription)
                } else if let activities = activities as? [Activity] {
                    let friends = activities.flatMap { $0[Constants.ActivityKey.toUser] as? User }
                    arrayOfFollowers.appendContentsOf(friends)
                }
                query.whereKey("user", containedIn: arrayOfFollowers)
                self?.fetchPosts(query, completion: completion)
            }
        } else {
            fetchPosts(query, completion: completion)
        }
    }

    fileprivate func fetchPosts(_ query: PFQuery, completion: @escaping LoadingPostsCompletion) {
        var posts = [Post]()
        query.findObjectsInBackgroundWithBlock { objects, error in
            if let objects = objects {
                for object in objects {
                    posts.append(object as! Post)
                    object.saveEventually()
                }
                completion(posts: posts, error: nil)
            } else if let error = error {
                log.debug(error.localizedDescription)
                completion(posts: nil, error: error)
            } else {
                completion(posts: nil, error: nil)
            }
        }
    }

}
