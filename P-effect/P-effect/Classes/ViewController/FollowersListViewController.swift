//
//  FollowersViewController.swift
//  P-effect
//
//  Created by anna on 3/3/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

final class FollowersListViewController: UIViewController, StoryboardInitable {
    
    static let storyboardName = Constants.Storyboard.Profile
    
    private var router: protocol<ProfilePresenter, AlertManagerDelegate>!
    
    private var user: User!
    private var followType: FollowType = .Followers
    
    private lazy var followerAdapter = FollowerAdapter()
    private weak var locator: ServiceLocator!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupNavigavionBar()
        setupAdapter()
    }
    
    func setLocator(locator: ServiceLocator) {
        self.locator = locator
    }
    
    func setUser(user: User) {
        self.user = user
    }
    
    func setFollowType(type: FollowType) {
        self.followType = type
    }
    
    func setRouter(router: FollowersListRouter) {
        self.router = router
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.registerNib(FollowerViewCell.cellNib, forCellReuseIdentifier: FollowerViewCell.identifier)
    }
    
    private func setupNavigavionBar() {
        navigationItem.title = followType.rawValue
    }
    
    private func setupAdapter() {
        tableView.dataSource = followerAdapter
        followerAdapter.delegate = self
        let cache = AttributesCache.sharedCache
        let activityService: ActivityService = router.locator.getService()
        
        switch followType {
        case .Followers :
            guard let attributes = cache.attributesForUser(user),
                cachedFollowers = attributes[Constants.Attributes.Followers] as? [User] else {
                    activityService.fetchFollowers(forUser: user) { [weak self] followers, error in
                        if let followers = followers {
                            self?.followerAdapter.update(withFollowers: followers, action: .Reload)
                        }
                    }
                    break
            }
            self.followerAdapter.update(withFollowers: cachedFollowers, action: .Reload)
            
        case .Following :
            guard let attributes = cache.attributesForUser(user),
                cachedFollowing = attributes[Constants.Attributes.Following] as? [User] else {
                    activityService.fetchFollowing(forUser: user) { [weak self] following, error in
                        if let following = following {
                            self?.followerAdapter.update(withFollowers: following, action: .Reload)
                        }
                    }
                    break
            }
            self.followerAdapter.update(withFollowers: cachedFollowing, action: .Reload)
        }
    }
    
}

extension FollowersListViewController: FollowerAdapterDelegate {
    
    func followerAdapterRequestedViewUpdate(adapter: FollowerAdapter) {
        tableView.reloadData()
    }
    
}

extension FollowersListViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let follower = followerAdapter.getFollower(atIndexPath: indexPath)
        router.showProfile(follower)
    }
    
}
