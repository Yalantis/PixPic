//
//  FollowersViewController.swift
//  PixPic
//
//  Created by anna on 3/3/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

typealias FollowersListRouterInterface = protocol<ProfilePresenter, AlertManagerDelegate>

final class FollowersListViewController: UIViewController, StoryboardInitiable {
    
    static let storyboardName = Constants.Storyboard.Profile
    
    private var router: FollowersListRouterInterface!
    
    private var user: User!
    private var followType: FollowType = .Followers
    
    private lazy var followerAdapter = FollowerAdapter()
    private weak var locator: ServiceLocator!
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupAdapter()
        setupObserver()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        AlertManager.sharedInstance.setAlertDelegate(router)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Setup methods
    func setLocator(locator: ServiceLocator) {
        self.locator = locator
    }
    
    func setUser(user: User) {
        self.user = user
    }
    
    func setFollowType(type: FollowType) {
        self.followType = type
    }
    
    func setRouter(router: FollowersListRouterInterface) {
        self.router = router
    }
    
    // MARK: - Private methods
    private func setupTableView() {
        tableView.delegate = self
        tableView.registerNib(FollowerViewCell.cellNib, forCellReuseIdentifier: FollowerViewCell.id)
    }
    
    private func setupAdapter() {
        tableView.dataSource = followerAdapter
        followerAdapter.delegate = self
        let cache = AttributesCache.sharedCache
        let activityService: ActivityService = locator.getService()
        
        let isFollowers = (followType == .Followers)
        let key = isFollowers ? Constants.Attributes.Followers : Constants.Attributes.Following
        
        if let attributes = cache.attributes(for: user), cachedUsers = attributes[key] as? [User] {
            self.followerAdapter.update(withFollowers: cachedUsers, action: .Reload)
        }
        
        activityService.fetchFollowers(followType, forUser: user) { [weak self] followers, _ in
            if let followers = followers {
                self?.followerAdapter.update(withFollowers: followers, action: .Reload)
            }
        }
    }
    
    private func setupObserver() {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(updateData),
            name: Constants.NotificationName.FollowersListIsUpdated,
            object: nil
        )
    }
    
    @objc private func updateData() {
        setupAdapter()
    }
}

// MARK: - FollowerAdapterDelegate methods
extension FollowersListViewController: FollowerAdapterDelegate {
    
    func followerAdapterRequestedViewUpdate(adapter: FollowerAdapter) {
        tableView.reloadData()
    }

}

// MARK: - UITableViewDelegate methods
extension FollowersListViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let follower = followerAdapter.getFollower(atIndexPath: indexPath)
        router.showProfile(follower)
    }
    
}

// MARK: - NavigationControllerAppearanceContext methods
extension FollowersListViewController: NavigationControllerAppearanceContext {
    
    func preferredNavigationControllerAppearance(navigationController: UINavigationController) -> Appearance? {
        var appearance = Appearance()
        appearance.title = followType.rawValue
        return appearance
    }
    
}
