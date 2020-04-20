//
//  ProfileViewController.swift
//  PixPic
//
//  Created by Illya on 1/18/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import Toast

typealias ProfileRouterInterface = EditProfilePresenter & FollowersListPresenter & AuthorizationPresenter & FeedPresenter & AlertManagerDelegate

enum FollowStatus: Int {

    case following, notFollowing, unknown
    
}


private let unfollowMessage = NSLocalizedString("sure_unfollow", comment: "")
private let unfollowTitle = NSLocalizedString("unfollow", comment: "")
private let unfollowActionTitle = NSLocalizedString("yes", comment: "")
private let cancelActionTitle = NSLocalizedString("cancel", comment: "")

private let followButtonMinHeight: CGFloat = 0.01
private let followButtonMaxHeight: CGFloat = 30

private let headerMaxHeight: CGFloat = 343
private let followButtonVerticalInset: CGFloat = 15
private let headerMinHeight: CGFloat = headerMaxHeight - followButtonMaxHeight - followButtonVerticalInset

final class ProfileViewController: BaseUITableViewController, StoryboardInitiable {

    static let storyboardName = Constants.Storyboard.profile
    fileprivate var router: ProfileRouterInterface!
    fileprivate var userId: String?

    var user: User? {
        didSet {
            reloadData()
        }
    }
    fileprivate var userInfo: AnyObject? {
        didSet {
            if user != nil, let postId = userInfo as? String {
                scrollToPost(postId, animated: true)
            }
        }
    }
    fileprivate weak var locator: ServiceLocator!
    fileprivate var activityShown: Bool?
    fileprivate lazy var postAdapter: PostAdapter = PostAdapter(locator: self.locator)
    fileprivate lazy var settingsMenu = SettingsMenu()

    fileprivate var followStatus = FollowStatus.unknown {
        didSet {
            switch followStatus {
            case .following:
                followButton.isSelected = true
                followButton.isEnabled = true
            case .notFollowing:
                followButton.isSelected = false
                followButton.isEnabled = true
            case .unknown:
                followButton.isEnabled = false
            }
        }
    }
    fileprivate var timeoutTimer: Timer!

    @IBOutlet fileprivate weak var profileSettingsButton: UIBarButtonItem!
    @IBOutlet fileprivate weak var userAvatar: UIImageView!
    @IBOutlet fileprivate weak var userName: UILabel!
    @IBOutlet fileprivate weak var tableViewFooter: UIView!
    @IBOutlet fileprivate weak var tableViewHeader: UIView!

    @IBOutlet fileprivate weak var followersQuantity: UILabel!
    @IBOutlet fileprivate weak var followingQuantity: UILabel!
    @IBOutlet fileprivate weak var followButton: UIButton!

    @IBOutlet fileprivate weak var followButtonHeight: NSLayoutConstraint!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupController()
        setupUserImagePlaceholder()
        setupLoadersCallback()
        setupGestureRecognizers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        AlertManager.sharedInstance.setAlertDelegate(router)
    }

    deinit {
        deleteTimer()
    }

    // MARK: - Setup methods
    func setLocator(_ locator: ServiceLocator) {
        self.locator = locator
    }

    func setUserInfo(_ userInfo: AnyObject?) {
        self.userInfo = userInfo
    }

    func setUserId(_ userId: String) {
        self.userId = userId
        let userService: UserService = locator.getService()
        userService.fetchUser(userId) { [weak self] user, error in
            if let error = error {
                log.debug(error.localizedDescription)
            } else {
                self?.user = user
            }
        }
    }

    func setRouter(_ router: ProfileRouterInterface) {
        self.router = router
    }

    // MARK: - Private methods
    fileprivate func setupController() {
        tableView.dataSource = postAdapter
        postAdapter.delegate = self
        tableView.registerNib(PostViewCell.cellNib, forCellReuseIdentifier: PostViewCell.id)
        profileSettingsButton.tintColor = .clear
        setupTableViewFooter()
    }

    fileprivate func reloadData() {
        showToast()
        updateUser()
        loadUserPosts()
        checkIsFollowing()
        fillFollowersQuantity(user!)
    }

    fileprivate func checkIsFollowing() {
        guard let user = user else {
            followStatus = .unknown

            return
        }
        let cache = AttributesCache.sharedCache
        let status = cache.followStatus(for: user)!
        if status == .unknown {
            let activityService: ActivityService = locator.getService()
            activityService.checkFollowingStatus(user) { [weak self] follow in
                self?.followStatus = follow
            }
        } else {
            followStatus = status
        }
    }

    fileprivate func loadUserPosts() {
        guard let user = user else {
            return
        }
        let postService: PostService = locator.getService()
        postService.loadPosts(user) { [weak self] objects, error in
            guard let this = self else {
                return
            }
            if let objects = objects {
                this.postAdapter.update(withPosts: objects, action: .reload)
                this.view.hideToastActivity()

                if let postId = this.userInfo as? String {
                    let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: delayTime) {
                        this.scrollToPost(postId, animated: true)
                    }
                }
            } else if let error = error {
                log.debug(error.localizedDescription)
            }
        }
    }

    fileprivate func scrollToPost(_ postId: String, animated: Bool) {
        if let indexPath = postAdapter.getPostIndexPath(postId) {
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Middle, animated: animated)
        }
    }

    fileprivate func setupTableViewFooter() {
        let screenSize = view.bounds
        var frame = tableViewFooter.frame
        if let navigationController = navigationController {
            frame.size.height = (screenSize.height - Constants.Profile.headerHeight -
                navigationController.navigationBar.frame.size.height)
        } else {
            frame.size.height = Constants.Profile.possibleInsets
        }
        tableViewFooter.frame = frame
        tableView.tableFooterView = tableViewFooter
    }

    fileprivate func setupGestureRecognizers() {
        let followersGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                action: #selector(didTapFollowersLabel(_:)))
        followersQuantity.addGestureRecognizer(followersGestureRecognizer)

        let followingGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                action: #selector(didTapFollowingLabel(_:)))
        followingQuantity.addGestureRecognizer(followingGestureRecognizer)
    }
    fileprivate func setupUserImagePlaceholder() {
        userAvatar.layer.cornerRadius = Constants.Profile.avatarImageCornerRadius
        userAvatar.image = UIImage(named: Constants.Profile.avatarImagePlaceholderName)
    }

    fileprivate func applyCurrentUserAppearance() {
        profileSettingsButton.isEnabled = true
        profileSettingsButton.tintColor = .appWhiteColor()

        followButton.isHidden = true
        followButtonHeight.constant = followButtonMinHeight

        tableViewHeader.frame = CGRect(x: tableViewHeader.frame.origin.x,
                                       y: tableViewHeader.frame.origin.y,
                                       width: tableViewHeader.frame.size.width,
                                       height: headerMinHeight)
        tableView.tableHeaderView = tableViewHeader
    }

    fileprivate func updateUser() {
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

    fileprivate func showToast() {
        view.showToastActivityWithDuration(Constants.Profile.toastActivityDuration)
        activityShown = true
    }

    fileprivate func deleteTimer() {
        timeoutTimer?.invalidate()
        timeoutTimer = nil
    }

    fileprivate func setupLoadersCallback() {
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
            this.timeoutTimer = NSTimer.scheduledTimerWithTimeInterval(Constants.Network.timeoutTimeInterval,
            repeats: false) {
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

    fileprivate func toggleFollowFriend() {
        guard let user = user else {
            return
        }

        let activityService: ActivityService = locator.getService()
        if followStatus == .following {
            // Unfollow

            let alertController = UIAlertController(
                title: unfollowTitle,
                message: unfollowMessage,
                preferredStyle: .actionSheet
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
                guard let this = self, let user = this.user else {
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
                            Constants.NotificationName.followersListIsUpdated,
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
            followStatus = .unknown
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
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
                    this.followStatus = .following
                } else {
                    this.followStatus = .notFollowing
                }
                indicator.removeFromSuperview()
                this.fillFollowersQuantity(user)
                NotificationCenter.default.post(
                    name: Notification.Name(rawValue: Constants.NotificationName.followersListIsUpdated),
                    object: nil
                )
            }
        }
    }

    fileprivate func fillFollowersQuantity(_ user: User) {
        let attributes = AttributesCache.sharedCache.attributes(for: user)
        if let followersQuantity = attributes?[Constants.Attributes.followersCount],
            let followingQuantity = attributes?[Constants.Attributes.followingCount] {
            self.followersQuantity.text = String(describing: followersQuantity) + " followers"
            self.followingQuantity.text = String(describing: followingQuantity) + " following"
        }

        let activityService: ActivityService = locator.getService()
        activityService.fetchFollowersQuantity(user) { [weak self] followersCount, followingCount in
            if let this = self {
                this.followersQuantity.text = String(followersCount) + " followers"
                this.followingQuantity.text = String(followingCount) + " following"
            }
        }
    }

    // MARK: - IBActions
    @IBAction fileprivate func followSomeone() {
        guard ReachabilityHelper.isReachable() else {
            ExceptionHandler.handle(Exception.NoConnection)

            return
        }
        if User.notAuthorized {
            AlertManager.sharedInstance.showLoginAlert(.Follow)
        } else {
            toggleFollowFriend()
        }
    }

    @IBAction fileprivate func profileSettings() {
        router.showEditProfile()
    }

    @objc fileprivate func didTapFollowersLabel(_ recognizer: UIGestureRecognizer) {
        guard let user = user else {
            return
        }
        let attributes = AttributesCache.sharedCache.attributes(for: user)
        guard let followersQuantity = attributes?[Constants.Attributes.followersCount] as? Int else {
            return
        }

        if followersQuantity != 0 {
            router.showFollowersList(user, followType: .Followers)
        }
    }

    @objc fileprivate func didTapFollowingLabel(_ recognizer: UIGestureRecognizer) {
        guard let user = user else {
            return
        }

        let attributes = AttributesCache.sharedCache.attributes(for: user)
        guard let followingQuantity = attributes?[Constants.Attributes.followingCount] as? Int else {
            return
        }

        if followingQuantity != 0 {
            router.showFollowersList(user, followType: .Following)
        }
    }

}

// MARK: - PostAdapterDelegate methods
extension ProfileViewController: PostAdapterDelegate {

    func showSettingsMenu(_ adapter: PostAdapter, post: Post, index: Int, items: [AnyObject]) {
        settingsMenu.locator = locator
        settingsMenu.showInViewController(self, forPost: post, atIndex: index, items: items)

        settingsMenu.postRemovalHandler = { [weak self] index in
            guard let this = self else {
                return
            }
            this.postAdapter.removePost(atIndex: index)
            this.tableView.reloadData()
        }
    }

    func showPlaceholderForEmptyDataSet(_ adapter: PostAdapter) {
        tableView.reloadData()
    }

    func postAdapterRequestedViewUpdate(_ adapter: PostAdapter) {
        tableView.reloadData()
    }

}

// MARK: - UITableViewDelegate methods
extension ProfileViewController {

    override func tableView(_ tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: IndexPath) {
        if activityShown == true {
            view.hideToastActivity()
            tableView.tableFooterView = nil
            tableView.isScrollEnabled = true
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.size.width + PostViewCell.designedHeight
    }

}

// MARK: - NavigationControllerAppearanceContext methods
extension ProfileViewController: NavigationControllerAppearanceContext {

    func preferredNavigationControllerAppearance(_ navigationController: UINavigationController) -> Appearance? {
        var appearance = Appearance()
        appearance.title = Constants.Profile.navigationTitle
        return appearance
    }

}
