//
//  FollowersViewController.swift
//  PixPic
//
//  Created by anna on 3/3/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

typealias FollowersListRouterInterface = ProfilePresenter & AlertManagerDelegate

final class FollowersListViewController: UIViewController, StoryboardInitiable {

    static let storyboardName = Constants.Storyboard.profile

    fileprivate var router: FollowersListRouterInterface!

    fileprivate var user: User!
    fileprivate var followType: FollowType = .Followers

    fileprivate lazy var followerAdapter = FollowerAdapter()
    fileprivate weak var locator: ServiceLocator!

    @IBOutlet weak var tableView: UITableView!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupAdapter()
        setupObserver()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        AlertManager.sharedInstance.setAlertDelegate(router)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup methods
    func setLocator(_ locator: ServiceLocator) {
        self.locator = locator
    }

    func setUser(_ user: User) {
        self.user = user
    }

    func setFollowType(_ type: FollowType) {
        self.followType = type
    }

    func setRouter(_ router: FollowersListRouterInterface) {
        self.router = router
    }

    // MARK: - Private methods
    fileprivate func setupTableView() {
        tableView.delegate = self
        tableView.registerNib(FollowerViewCell.cellNib, forCellReuseIdentifier: FollowerViewCell.id)
    }

    fileprivate func setupAdapter() {
        tableView.dataSource = followerAdapter as! UITableViewDataSource
        followerAdapter.delegate = self
        let cache = AttributesCache.sharedCache
        let activityService: ActivityService = locator.getService()

        let isFollowers = (followType == .Followers)
        let key = isFollowers ? Constants.Attributes.followers : Constants.Attributes.following

        if let attributes = cache.attributes(for: user), let cachedUsers = attributes[key] as? [User] {
            self.followerAdapter.update(withFollowers: cachedUsers, action: .reload)
        }

        activityService.fetchFollowers(followType, forUser: user) { [weak self] followers, _ in
            if let followers = followers {
                self?.followerAdapter.update(withFollowers: followers, action: .reload)
            }
        }
    }

    fileprivate func setupObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateData),
            name: NSNotification.Name(rawValue: Constants.NotificationName.followersListIsUpdated),
            object: nil
        )
    }

    @objc fileprivate func updateData() {
        setupAdapter()
    }

}

// MARK: - FollowerAdapterDelegate methods
extension FollowersListViewController: FollowerAdapterDelegate {

    func followerAdapterRequestedViewUpdate(_ adapter: FollowerAdapter) {
        tableView.reloadData()
    }

}

// MARK: - UITableViewDelegate methods
extension FollowersListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let follower = followerAdapter.getFollower(atIndexPath: indexPath)
        router.showProfile(follower)
    }

}

// MARK: - NavigationControllerAppearanceContext methods
extension FollowersListViewController: NavigationControllerAppearanceContext {

    func preferredNavigationControllerAppearance(_ navigationController: UINavigationController) -> Appearance? {
        var appearance = Appearance()
        appearance.title = followType.rawValue
        return appearance
    }

}
