//
//  ProfileViewController.swift
//  P-effect
//
//  Created by Illya on 1/18/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import Toast

private let unfollowMessage = "Are you sure you want to unfollow?"
private let unfollowTitle = "Unfollow"
private let unfollowActionTitle = "Yes"

private let suggestLoginMessage = "You can't follow someone without registration"
private let registerActionTitle = "Register"
private let cancelActionTitle = "Cancel"

final class ProfileViewController: UITableViewController, StoryboardInitable {
    
    static let storyboardName = Constants.Storyboard.Profile
    private var router: protocol<EditProfilePresenter, FeedPresenter, FollowersListPresenter, AuthorizationPresenter, AlertManagerDelegate>!
    private var user: User? {
        didSet {
            updateSelf()
        }
    }
    private var userId: String?
    
    private weak var locator: ServiceLocator!
    private var activityShown: Bool?
    private lazy var postAdapter = PostAdapter()
    private lazy var settingsMenu = SettingsMenu()
    
    @IBOutlet private weak var profileSettingsButton: UIBarButtonItem!
    @IBOutlet private weak var userAvatar: UIImageView!
    @IBOutlet private weak var userName: UILabel!
    @IBOutlet private weak var tableViewFooter: UIView!
    
    @IBOutlet private weak var followersQuantity: UILabel!
    @IBOutlet private weak var followingQuantity: UILabel!
    @IBOutlet private weak var followButton: UIButton!
    
    @IBOutlet private weak var followButtonHeight: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupController()
        setupLoadersCallback()
        setupFollowButton()
        setupGestureRecognizers()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        AlertManager.sharedInstance.registerAlertListener(router)
        fillFollowersQuantity(user!)
    }
    
    // MARK: - Setup methods
    func setLocator(locator: ServiceLocator) {
        self.locator = locator
    }
    
    func setUser(user: User) {
        self.user = user
    }
    
    func setUserId(userId: String) {
        self.userId = userId
        let userService: UserService = locator.getService()
        userService.fetchUser(userId) { [weak self] user, error in
            if let error = error {
                log.debug(error.localizedDescription)
            } else {
                self?.setUser(user)
            }
        }
    }
    
    func setRouter(router: ProfileRouter) {
        self.router = router
    }
    
    // MARK: - Private methods
    private func updateSelf() {
        setupFollowButton()
        setupController()
    }
    
    private func setupController() {
        showToast()
        tableView.dataSource = postAdapter
        postAdapter.delegate = self
        tableView.registerNib(PostViewCell.cellNib, forCellReuseIdentifier: PostViewCell.identifier)
        setupTableViewFooter()
        applyUser()
        loadUserPosts()
    }
    
    private func setupFollowButton() {
        guard let user = user else {
            return
        }
        followButton?.selected = false
        followButton?.enabled = false
        let cache = AttributesCache.sharedCache
        if let followStatus = cache.followStatusForUser(user) {
            followButton?.selected = followStatus
            followButton?.enabled = true
        } else {
            let activityService: ActivityService = locator.getService()
            activityService.checkIsFollowing(user) { [weak self] follow in
                self?.followButton?.selected = follow
                self?.followButton?.enabled = true
            }
        }
    }
    
    private func loadUserPosts() {
        guard let user = user else {
            return
        }
        let postService: PostService = locator.getService()
        postService.loadPosts(user) { [weak self] objects, error in
            guard let this = self else {
                return
            }
            if let objects = objects {
                this.postAdapter.update(withPosts: objects, action: .Reload)
                this.view.hideToastActivity()
            } else if let error = error {
                log.debug(error.localizedDescription)
            }
        }
    }
    
    private func setupTableViewFooter() {
        let screenSize = view.bounds
        var frame = tableViewFooter.frame
        if let navigationController = navigationController {
            frame.size.height = (screenSize.height - Constants.Profile.HeaderHeight - navigationController.navigationBar.frame.size.height)
        } else {
            frame.size.height = Constants.Profile.PossibleInsets
        }
        tableViewFooter.frame = frame
        tableView.tableFooterView = tableViewFooter
    }
    
    private func setupGestureRecognizers() {
        let followersGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapFollowersLabel(_:)))
        followersQuantity.addGestureRecognizer(followersGestureRecognizer)
        
        let followingGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapFollowingLabel(_:)))
        followingQuantity.addGestureRecognizer(followingGestureRecognizer)
    }
    
    private func applyUser() {
        userAvatar.layer.cornerRadius = Constants.Profile.AvatarImageCornerRadius
        userAvatar.image = UIImage(named: Constants.Profile.AvatarImagePlaceholderName)
        guard let user = user else {
            return
        }
        userName.text = user.username
        
        guard let avatar = user.avatar else {
            return
        }
        
        ImageLoaderHelper.getImageForContentItem(avatar) { [weak self] image, error in
            guard let this = self else {
                return
            }
            if error == nil {
                this.userAvatar.image = image
            } else {
                this.view.makeToast(error?.localizedDescription)
            }
        }
        
        if user.isCurrentUser {
            profileSettingsButton.enabled = true
            profileSettingsButton.image = UIImage(named: Constants.Profile.SettingsButtonImage)
            profileSettingsButton.tintColor = UIColor.appWhiteColor

            followButton.hidden = true
            followButtonHeight.constant = 0.1
        }
        fillFollowersQuantity(user)
    }
    
    private func showToast() {
        let toastActivityHelper = ToastActivityHelper()
        toastActivityHelper.showToastActivityOn(view, duration: Constants.Profile.ToastActivityDuration)
        activityShown = true
    }
    
    private func setupLoadersCallback() {
        let postService: PostService = locator.getService()
        tableView.addPullToRefreshWithActionHandler { [weak self] in
            guard let this = self else {
                return
            }
            
            guard ReachabilityHelper.isReachable() else {
                ExceptionHandler.handle(Exception.NoConnection)
                this.tableView.pullToRefreshView.stopAnimating()

                return
            }
                
            postService.loadPosts(this.user) { objects, error in
                if let objects = objects {
                    this.postAdapter.update(withPosts: objects, action: .Reload)
                    AttributesCache.sharedCache.clear()
                } else if let error = error {
                    log.debug(error.localizedDescription)
                }
                this.tableView.pullToRefreshView.stopAnimating()
            }
        }
        tableView.addInfiniteScrollingWithActionHandler { [weak self] in
            guard let this = self else {
                return
            }
            postService.loadPagedPosts(this.user, offset: this.postAdapter.postQuantity) { objects, error in
                if let objects = objects {
                    this.postAdapter.update(withPosts: objects, action: .LoadMore)
                } else if let error = error {
                    log.debug(error.localizedDescription)
                }
                this.tableView.infiniteScrollingView.stopAnimating()
            }
        }
    }
    
    private func toggleFollowFriend() {
        guard let user = user else {
            return
        }
        let activityService: ActivityService = locator.getService()
        if followButton.selected {
            // Unfollow
            followButton.enabled = false
            
            let alertController = UIAlertController(
                title: unfollowTitle,
                message: unfollowMessage,
                preferredStyle: .ActionSheet
            )
            let cancelAction = UIAlertAction(
                title: cancelActionTitle,
                style: .Cancel
                ) { [weak self] _ in
                    self?.followButton.enabled = true
            }
            let unfollowAction = UIAlertAction(
                title: unfollowActionTitle,
                style: .Default
                ) { [weak self] _ in
                    guard let this = self, user = this.user else {
                        return
                    }
                    activityService.unfollowUserEventually(user) { [weak self] success, error in
                        if success {
                            guard let this = self else {
                                return
                            }
                            this.followButton.selected = false
                            this.followButton.enabled = true
                            this.fillFollowersQuantity(user)
                            NSNotificationCenter.defaultCenter().postNotificationName(
                                Constants.NotificationName.FollowersListUpdated,
                                object: nil
                            )
                        }
                    }
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(unfollowAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        } else {
            // Follow
            followButton.selected = true
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
            indicator.center = followButton.center
            indicator.hidesWhenStopped = true
            indicator.startAnimating()
            followButton.addSubview(indicator)
            activityService.followUserEventually(user) { [weak self] succeeded, error in
                guard let this = self else {
                    return
                }
                if error == nil {
                    log.debug("Attempt to follow was \(succeeded) ")
                    this.followButton.selected = true
                } else {
                    this.followButton.selected = false
                }
                indicator.removeFromSuperview()
                this.fillFollowersQuantity(user)
                NSNotificationCenter.defaultCenter().postNotificationName(
                    Constants.NotificationName.FollowersListUpdated,
                    object: nil
                )
            }
        }
    }
    
    private func fillFollowersQuantity(user: User) {
        let attributes = AttributesCache.sharedCache.attributesForUser(user)
        if let followersQuantity = attributes?[Constants.Attributes.FollowersCount],
            followingQuantity = attributes?[Constants.Attributes.FollowingCount] {
                self.followersQuantity.text = String(followersQuantity) + " followers"
                self.followingQuantity.text = String(followingQuantity) + " following"
        }

        let activityService: ActivityService = locator.getService()
        activityService.fetchFollowersQuantity(user) { [weak self] followersCount, followingCount in
            if let this = self {
                this.followersQuantity.text = String(followersCount) + " followers"
                this.followingQuantity.text = String(followingCount) + " following"
            }
        }

    }
    
    private func suggestLogin() {
        let alertController = UIAlertController(title: suggestLoginMessage, message: "", preferredStyle: .Alert)
        let cancelAction = UIAlertAction(
            title: cancelActionTitle,
            style: .Cancel,
            handler: nil)
        
        let registerAction = UIAlertAction(
            title: registerActionTitle,
            style: .Default
            ) { [weak self] _ in
                self?.router.showAuthorization()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(registerAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - IBActions
    @IBAction private func followSomeone() {
        guard ReachabilityHelper.isReachable() else {
            ExceptionHandler.handle(Exception.NoConnection)
            
            return
        }
        if User.notAuthorized {
            suggestLogin()
        } else {
            toggleFollowFriend()
        }
    }
    
    @IBAction private func profileSettings() {
        router.showEditProfile()
    }

    @objc private func didTapFollowersLabel(recognizer: UIGestureRecognizer) {
        guard let user = user else {
            return
        }
        let attributes = AttributesCache.sharedCache.attributesForUser(user)
        guard let followersQuantity = attributes?[Constants.Attributes.FollowersCount] as? Int else {
            return
        }
        
        if followersQuantity != 0 {
            router.showFollowersList(user, followType: .Followers)
        }
    }
    
    @objc private func didTapFollowingLabel(recognizer: UIGestureRecognizer) {
        guard let user = user else {
            return
        }
        
        let attributes = AttributesCache.sharedCache.attributesForUser(user)
        guard let followingQuantity = attributes?[Constants.Attributes.FollowingCount] as? Int else {
            return
        }

        if followingQuantity != 0 {
            router.showFollowersList(user, followType: .Following)
        }
    }
    
}

// MARK: - PostAdapterDelegate methods
extension ProfileViewController: PostAdapterDelegate {
    
    func showSettingsMenu(adapter: PostAdapter, post: Post, index: Int, items: [AnyObject]) {
        settingsMenu.locator = locator
        settingsMenu.showInViewController(self, forPost: post, atIndex: index, items: items)
        settingsMenu.userAuthorizationHandler = { [weak self] in
            self?.router.showAuthorization()
        }
        
        settingsMenu.postRemovalHandler = { [weak self] index in
            guard let this = self else {
                return
            }
            this.postAdapter.removePost(atIndex: index)
            this.tableView.reloadData()
        }
    }
    
    func showPlaceholderForEmptyDataSet(adapter: PostAdapter) {
        tableView.reloadData()
    }
    
    func postAdapterRequestedViewUpdate(adapter: PostAdapter) {
        tableView.reloadData()
    }
    
}

// MARK: - UITableViewDelegate methods
extension ProfileViewController {
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if activityShown == true {
            view.hideToastActivity()
            tableView.tableFooterView = nil
            tableView.scrollEnabled = true
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.bounds.size.width + PostViewCell.designedHeight
    }
    
}

// MARK: - NavigationControllerAppearanceContext methods
extension ProfileViewController: NavigationControllerAppearanceContext {
    
    func preferredNavigationControllerAppearance(navigationController: UINavigationController) -> Appearance? {
        var appearance = Appearance()
        appearance.title = Constants.Profile.NavigationTitle
        return appearance
    }
    
}

