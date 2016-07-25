//
//  ProfileViewController.swift
//  PixPic
//
//  Created by Illya on 1/18/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import Toast

typealias ProfileRouterInterface = protocol<EditProfilePresenter, FollowersListPresenter, AuthorizationPresenter, FeedPresenter, AlertManagerDelegate>

enum FollowStatus: Int {
    case Following, NotFollowing, Unknown
}

enum LikeStatus: Int {
    case Liked, NotLiked, Unknown
}

private let unfollowMessage = NSLocalizedString("sure_unfollow", comment: "")
private let unfollowTitle = NSLocalizedString("unfollow", comment: "")
private let unfollowActionTitle = NSLocalizedString("yes", comment: "")

private let suggestLoginMessage = NSLocalizedString("can't_follow_no_registration", comment: "")
private let registerActionTitle = NSLocalizedString("register", comment: "")
private let cancelActionTitle = NSLocalizedString("cancel", comment: "")

private let followButtonMinHeight: CGFloat = 0.01
private let followButtonMaxHeight: CGFloat = 30

private let headerMaxHeight: CGFloat = 343
private let followButtonVerticalInset: CGFloat = 15
private let headerMinHeight: CGFloat = headerMaxHeight - followButtonMaxHeight - followButtonVerticalInset

final class ProfileViewController: BaseUITableViewController, StoryboardInitiable {
    
    static let storyboardName = Constants.Storyboard.Profile
    private var router: ProfileRouterInterface!
    private var user: User? {
        didSet {
            reloadData()
        }
    }
    private var userId: String?
    
    private weak var locator: ServiceLocator!
    private var activityShown: Bool?
    private lazy var postAdapter = PostAdapter()
    private lazy var settingsMenu = SettingsMenu()
    
    private var followStatus = FollowStatus.Unknown {
        didSet {
            switch followStatus {
            case .Following:
                followButton.selected = true
                followButton.enabled = true
            case .NotFollowing:
                followButton.selected = false
                followButton.enabled = true
            case .Unknown:
                followButton.enabled = false
            }
        }
    }
    private var timeoutTimer: NSTimer!
    
    @IBOutlet private weak var profileSettingsButton: UIBarButtonItem!
    @IBOutlet private weak var userAvatar: UIImageView!
    @IBOutlet private weak var userName: UILabel!
    @IBOutlet private weak var tableViewFooter: UIView!
    @IBOutlet private weak var tableViewHeader: UIView!
    
    @IBOutlet private weak var followersQuantity: UILabel!
    @IBOutlet private weak var followingQuantity: UILabel!
    @IBOutlet private weak var followButton: UIButton!
    
    @IBOutlet private weak var followButtonHeight: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupController()
        setupUserImagePlaceholder()
        setupLoadersCallback()
        setupGestureRecognizers()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        AlertManager.sharedInstance.setAlertDelegate(router)
        fillFollowersQuantity(user!)
    }
    
    deinit {
        deleteTimer()
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
    
    func setRouter(router: ProfileRouterInterface) {
        self.router = router
    }
    
    // MARK: - Private methods
    private func setupController() {
        tableView.dataSource = postAdapter
        postAdapter.delegate = self
        tableView.registerNib(PostViewCell.cellNib, forCellReuseIdentifier: PostViewCell.id)
        profileSettingsButton.tintColor = .clearColor()
        setupTableViewFooter()
    }
    
    private func reloadData() {
        showToast()
        updateUser()
        loadUserPosts()
        checkIsFollowing()
    }
    
    private func checkIsFollowing() {
        guard let user = user else {
            followStatus = .Unknown
            
            return
        }
        let cache = AttributesCache.sharedCache
        let status = cache.followStatus(for: user)!
        if status == .Unknown {
            let activityService: ActivityService = locator.getService()
            activityService.checkFollowingStatus(user) { [weak self] follow in
                self?.followStatus = follow
            }
        } else {
            followStatus = status
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
    private func setupUserImagePlaceholder() {
        userAvatar.layer.cornerRadius = Constants.Profile.AvatarImageCornerRadius
        userAvatar.image = UIImage(named: Constants.Profile.AvatarImagePlaceholderName)
    }
    
    private func applyCurrentUserAppearance() {
        profileSettingsButton.enabled = true
        profileSettingsButton.tintColor = .appWhiteColor()
        
        followButton.hidden = true
        followButtonHeight.constant = followButtonMinHeight
        
        tableViewHeader.frame = CGRect(x: tableViewHeader.frame.origin.x, y: tableViewHeader.frame.origin.y, width: tableViewHeader.frame.size.width, height: headerMinHeight)
        tableView.tableHeaderView = tableViewHeader
    }
    
    private func updateUser() {
        guard let user = user else {
            return
        }
        userName.text = user.username
        
        guard let avatar = user.avatar else {
            return
        }
        
        avatar.getImage { [weak self] image, error in
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
            applyCurrentUserAppearance()
        }
        
        fillFollowersQuantity(user)
    }
    
    private func showToast() {
        view.showToastActivityWithDuration(Constants.Profile.ToastActivityDuration)
        activityShown = true
    }
    
    private func deleteTimer() {
        timeoutTimer?.invalidate()
        timeoutTimer = nil
    }
    
    private func setupLoadersCallback() {
        let postService: PostService = locator.getService()
        tableView.addPullToRefreshWithActionHandler { [weak self] in
            guard let this = self else {
                return
            }
            
            let noConnection = {
                ExceptionHandler.handle(Exception.NoConnection)
                this.tableView.pullToRefreshView.stopAnimating()
                this.deleteTimer()
                
                return
            }
            this.timeoutTimer = NSTimer.scheduledTimerWithTimeInterval(Constants.Network.TimeoutTimeInterval, repeats: false) {
                noConnection()
            }
            guard ReachabilityHelper.isReachable() else {
                noConnection()
                
                return
            }
            
            postService.loadPosts(this.user) { objects, error in
                this.deleteTimer()
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
        if followStatus == .Following {
            // Unfollow
            
            let alertController = UIAlertController(
                title: unfollowTitle,
                message: unfollowMessage,
                preferredStyle: .ActionSheet
            )
            let cancelAction = UIAlertAction.appAlertAction(
                title: cancelActionTitle,
                style: .Cancel
            ) { [weak self] _ in
                self?.followButton.enabled = true
            }
            let unfollowAction = UIAlertAction.appAlertAction(
                title: unfollowActionTitle,
                style: .Default
            ) { [weak self] _ in
                guard let this = self, user = this.user else {
                    return
                }
                this.followStatus = .Unknown
                activityService.unfollowUserEventually(user) { [weak self] success, error in
                    if success {
                        guard let this = self else {
                            return
                        }
                        this.followStatus = .NotFollowing
                        this.fillFollowersQuantity(user)
                        NSNotificationCenter.defaultCenter().postNotificationName(
                            Constants.NotificationName.FollowersListIsUpdated,
                            object: nil
                        )
                    } else {
                        this.followStatus = .Following
                    }
                }
            }
            
            alertController.addAction(cancelAction)
            alertController.addAction(unfollowAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        } else {
            // Follow
            followStatus = .Unknown
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
                    this.followStatus = .Following
                } else {
                    this.followStatus = .NotFollowing
                }
                indicator.removeFromSuperview()
                this.fillFollowersQuantity(user)
                NSNotificationCenter.defaultCenter().postNotificationName(
                    Constants.NotificationName.FollowersListIsUpdated,
                    object: nil
                )
            }
        }
    }
    
    private func fillFollowersQuantity(user: User) {
        let attributes = AttributesCache.sharedCache.attributes(for: user)
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
        let cancelAction = UIAlertAction.appAlertAction(
            title: cancelActionTitle,
            style: .Cancel,
            handler: nil)
        
        let registerAction = UIAlertAction.appAlertAction(
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
        let attributes = AttributesCache.sharedCache.attributes(for: user)
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
        
        let attributes = AttributesCache.sharedCache.attributes(for: user)
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

