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
        
        let isFollowers = (followType == .Followers)
        let key = isFollowers ? Constants.Attributes.Followers : Constants.Attributes.Following
        
        guard let attributes = cache.attributesForUser(user),
            cachedUsers = attributes[key] as? [User] else {
                activityService.fetchUsers(followType, forUser: user) { [weak self] users, _ in
                    if let users = users {
                        self?.followerAdapter.update(withFollowers: users, action: .Reload)
                    }
                }
                return
        }
        self.followerAdapter.update(withFollowers: cachedUsers, action: .Reload)
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

extension FollowersListViewController: NavigationControllerAppearanceContext {
    
    func preferredNavigationControllerAppearance(navigationController: UINavigationController) -> Appearance? {
//        (self.navigationController as! AppearanceNavigationController).appearanceApplyingStrategy
        return Appearance()
    }
}
