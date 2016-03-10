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
    private var followType: FollowType!
    
    private lazy var followerAdapter = FollowerAdapter()
    private weak var locator: ServiceLocator!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupNavigavionBar()
        setupAdapter()
        setupLoadersCallback()
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
    }
    
    private func setupLoadersCallback() {
        tableView.addPullToRefreshWithActionHandler { [weak self] in
            guard let this = self else {
                return
            }
            guard ReachabilityHelper.checkConnection() else {
                this.tableView.pullToRefreshView.stopAnimating()
                return
            }

            this.tableView.pullToRefreshView.stopAnimating()
        }
        tableView.addInfiniteScrollingWithActionHandler { [weak self] in
            guard let this = self else {
                return
            }
            guard let offset = self?.followerAdapter.followersQuantity else {
                this.tableView.infiniteScrollingView.stopAnimating()
                return
            }

            this.tableView.infiniteScrollingView.stopAnimating()
        }
    }

}

extension FollowersListViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let follower = followerAdapter.getFollower(atIndexPath: indexPath)
        router.showProfile(follower)
    }
    
}
