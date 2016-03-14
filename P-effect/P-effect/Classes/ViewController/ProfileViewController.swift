//
//  ProfileViewController.swift
//  P-effect
//
//  Created by Illya on 1/18/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import Toast

private let removePostMessage = "This photo will be deleted from P-effect"

final class ProfileViewController: UITableViewController, StoryboardInitable {
    
    static let storyboardName = Constants.Storyboard.Profile
    
    private var router: protocol<EditProfilePresenter, FeedPresenter, FollowersListPresenter, AuthorizationPresenter, AlertManagerDelegate>!
    private var user: User!
    
    private weak var locator: ServiceLocator!
    private var activityShown: Bool?
    private lazy var postAdapter = PostAdapter()
    
    @IBOutlet private weak var profileSettingsButton: UIBarButtonItem!
    @IBOutlet private weak var userAvatar: UIImageView!
    @IBOutlet private weak var userName: UILabel!
    @IBOutlet private weak var tableViewFooter: UIView!
    
    @IBOutlet private weak var followersQuantity: UILabel!
    @IBOutlet private weak var followingQuantity: UILabel!
    @IBOutlet private weak var followButton: UIButton!
    
    @IBOutlet weak var followButtonHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupController()
        setupFollowButton()
        setupGestureRecognizers()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        AlertManager.sharedInstance.registerAlertListener(router)
    }
    
    // MARK: - Inner func
    func setLocator(locator: ServiceLocator) {
        self.locator = locator
    }
    
    func setUser(user: User) {
        self.user = user
    }
    
    func setRouter(router: ProfileRouter) {
        self.router = router
    }
    
    private func setupController() {
        showToast()
        tableView.dataSource = postAdapter
        postAdapter.delegate = self
        tableView.registerNib(PostViewCell.nib, forCellReuseIdentifier: PostViewCell.identifier)
        setupTableViewFooter()
        applyUser()
        loadUserPosts()
    }
    
    private func setupFollowButton() {
        followButton.selected = false
        followButton.enabled = false
        let cache = AttributesCache.sharedCache
        if let followStatus = cache.followStatusForUser(user) {
            followButton.selected = followStatus
            followButton.enabled = true
        } else {
            let activityService: ActivityService = router.locator.getService()
            activityService.checkIsFollowing(user) { [weak self] follow in
                self?.followButton.selected = follow
                self?.followButton.enabled = true
            }
        }
    }
    
    private func loadUserPosts() {
        let postService: PostService = locator.getService()
        postService.loadPosts(user) { [weak self] objects, error in
            guard let this = self else {
                return
            }
            if let objects = objects {
                this.postAdapter.update(withPosts: objects, action: .Reload)
                this.view.hideToastActivity()
            } else if let error = error {
                print(error)
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
        print(tableViewFooter.frame)
        tableView.tableFooterView = tableViewFooter;
    }
    
    private func setupGestureRecognizers() {
        let followersGestureRecognizer = UITapGestureRecognizer(target: self, action: "didTapFollowersLabel:")
        followersQuantity.addGestureRecognizer(followersGestureRecognizer)
        
        let followingGestureRecognizer = UITapGestureRecognizer(target: self, action: "didTapFollowingLabel:")
        followingQuantity.addGestureRecognizer(followingGestureRecognizer)
    }
    
    private func applyUser() {
        userAvatar.layer.cornerRadius = Constants.Profile.AvatarImageCornerRadius
        userAvatar.image = UIImage(named: Constants.Profile.AvatarImagePlaceholderName)
        userName.text = user.username
        navigationItem.title = Constants.Profile.NavigationTitle
        user.loadUserAvatar {[weak self] image, error in
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
            profileSettingsButton.tintColor = .whiteColor()
           
            followButton.hidden = true
            followButtonHeight.constant = 0.1
            
            print(followButtonHeight)
        }
        fillFollowersQuantity(user)
    }
    
    private func showToast() {
        let toastActivityHelper = ToastActivityHelper()
        toastActivityHelper.showToastActivityOn(view, duration: Constants.Profile.ToastActivityDuration)
        activityShown = true
    }
    
    @IBAction func followSomeone() {
        if ReachabilityHelper.checkConnection() {
            
            if PFAnonymousUtils.isLinkedWithUser(User.currentUser()) || User.isUserAbsent {
                let alertController = UIAlertController(title: "You can't follow someone without registration", message: "", preferredStyle: .Alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                
                let registerAction = UIAlertAction(title: "Register", style: .Default) { [weak self] _ in
                    self?.router.showAuthorization()
                }
                
                alertController.addAction(cancelAction)
                alertController.addAction(registerAction)
                
                presentViewController(alertController, animated: true, completion: nil)
            } else {
                toggleFollowFriend()
            }
        }
    }

    private func toggleFollowFriend() {
        let activityService: ActivityService = router.locator.getService()
        if followButton.selected {
            // Unfollow
            followButton.enabled = false
            
            let alertController = UIAlertController(title: "Unfollow", message: "Are you sure you want to unfollow?", preferredStyle: .ActionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { [weak self] _ in
                self?.followButton.enabled = true
            }
            
            let unfollowAction = UIAlertAction(title: "Yes", style: .Default) { [weak self] _ in
                guard let this = self else {
                    return
                }
                
                activityService.unfollowUserEventually(this.user) { [weak self] success, error in
                    if success {
                        self?.followButton.selected = false
                        self?.followButton.enabled = true
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
            activityService.followUserEventually(user) { succeeded, error in
                if error == nil {
                    print("Attempt to follow was \(succeeded) ")
                    self.followButton.selected = true
                } else {
                    self.followButton.selected = false
                }
                indicator.removeFromSuperview()
            }
        }
    }
    
    // MARK: - IBActions
    @IBAction private func profileSettings() {
        router.showEditProfile()
    }
    
    private func fillFollowersQuantity(user: User) {
        let attributes = AttributesCache.sharedCache.attributesForUser(user)
        guard let followersQt = attributes?[Constants.Attributes.FollowersCount],
            folowingQt = attributes?[Constants.Attributes.FollowingCount] else {
                let activityService: ActivityService = router.locator.getService()
                activityService.fetchFollowersQuantity(user) { [weak self] followersCount, followingCount in
                    if let this = self {
                        this.followersQuantity.text = String(followersCount) + " followers"
                        this.followingQuantity.text = String(followingCount) + " following"
                    }
                }
                return
        }
        followersQuantity.text = String(followersQt) + " followers"
        followingQuantity.text = String(folowingQt) + " following"
    }
    
    
    dynamic private func didTapFollowersLabel(recognizer: UIGestureRecognizer) {
        router.showFollowersList(user, followType: .Followers)
    }
    
    dynamic private func didTapFollowingLabel(recognizer: UIGestureRecognizer) {
        router.showFollowersList(user, followType: .Following)
    }
    
}

extension ProfileViewController: PostAdapterDelegate {
    
    func showSettingsMenu(adapter: PostAdapter, post: Post, index: Int, items: [AnyObject]) {
        if ReachabilityHelper.checkConnection() {
            
            let settingsMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            settingsMenu.addAction(cancelAction)
            
            let shareAction = UIAlertAction(title: "Share", style: .Default) { [weak self] _ in
                self?.showActivityController(items)
            }
            settingsMenu.addAction(shareAction)
            
            
            if post.user == User.currentUser() {
                let removeAction = UIAlertAction(title: "Remove post", style: .Default) { [weak self] _ in
                    self?.removePost(post, atIndex: index)
                }
                settingsMenu.addAction(removeAction)
                
            } else {
                let complaintAction = UIAlertAction(title: "Complain", style: .Default) { [weak self] _ in
                    self?.complaintToPost(post)
                }
                settingsMenu.addAction(complaintAction)
            }
            
            presentViewController(settingsMenu, animated: true, completion: nil)
            
        }
    }
    
    private func removePost(post: Post, atIndex index: Int) {
        UIAlertController.showAlert(
            inViewController: self,
            message: removePostMessage) { [weak self] _ in
                guard let this = self else {
                    return
                }
                
                let postService: PostService = this.locator.getService()
                postService.removePost(post) { succeeded, error in
                    if succeeded {
                        this.postAdapter.removePost(atIndex: index)
                        this.tableView.reloadData()
                    } else if let error = error?.localizedDescription {
                        print(error)
                    }
                }
        }
    }
    
    private func complaintToPost(post: Post) {
        let complaintMenu = UIAlertController(title: "Complain about", message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        complaintMenu.addAction(cancelAction)
        
        let complaintService: ComplaintService = router.locator.getService()
        let complaintUsernameAction = UIAlertAction(title: "Username", style: .Default) { _ in
            complaintService.complaintUsername(post.user!) { _, error in
                print(error)
            }
        }
        
        let complaintUserAvatarAction = UIAlertAction(title: "User avatar", style: .Default) { _ in
            complaintService.complaintUserAvatar(post.user!) { _, error in
                print(error)
            }
        }
        
        let complaintPostAction = UIAlertAction(title: "Post", style: .Default) { _ in
            complaintService.complaintPost(post) { _, error in
                print(error)
            }
        }
        
        complaintMenu.addAction(complaintUsernameAction)
        complaintMenu.addAction(complaintUserAvatarAction)
        complaintMenu.addAction(complaintPostAction)
        
        presentViewController(complaintMenu, animated: true, completion: nil)
        
    }
    
    private func showActivityController(items: [AnyObject]) {
        let activityViewController = ActivityViewController.initWith(items)
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }

    func showUserProfile(adapter: PostAdapter, user: User) {
        
    }
    
    func showPlaceholderForEmptyDataSet(adapter: PostAdapter) {
        tableView.reloadData()
    }
    
    func postAdapterRequestedViewUpdate(adapter: PostAdapter) {
        tableView.reloadData()
    }
    
}


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
