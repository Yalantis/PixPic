//
//  ProfileViewController.swift
//  P-effect
//
//  Created by Illya on 1/18/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import Toast

class ProfileViewController: UITableViewController, ApplicationAppearance {
    
    @IBOutlet weak var profileSettingsButton: UIBarButtonItem!
    @IBOutlet private weak var userAvatar: UIImageView!
    @IBOutlet private weak var userName: UILabel!
    @IBOutlet private weak var tableViewFooter: UIView!
    
    private var activityShown: Bool?
    private lazy var postAdapter = PostAdapter()
    private lazy var locator = ServiceLocator()

    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configurateNavigationBar()
        setupController()
        setupLoadersCallback()
        locator.registerService(ReachabilityService())
    }
    
    // MARK: - Inner func
    private func setupController() {
        locator.registerService(PostService())
        showToast()
        tableView.dataSource = postAdapter
        postAdapter.delegate = self
        tableView.registerNib(PostViewCell.nib, forCellReuseIdentifier: PostViewCell.identifier)
        setupTableViewFooter()
        applyUser()
        loadUserPosts()
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
        tableView.tableFooterView = tableViewFooter;
    }
    
    private func applyUser() {
        userAvatar.layer.cornerRadius = Constants.Profile.AvatarImageCornerRadius
        userAvatar.image = UIImage(named: Constants.Profile.AvatarImagePlaceholderName)
        userName.text = user.username
        navigationItem.title = Constants.Profile.NavigationTitle
        user.loadUserAvatar { [weak self] image, error in
            if error == nil {
                self?.userAvatar.image = image
            } else {
                self?.view.makeToast(error?.localizedDescription)
            }
        }
        if user.isCurrentUser {
            profileSettingsButton.enabled = true
            profileSettingsButton.image = UIImage(named: Constants.Profile.SettingsButtonImage)
            profileSettingsButton.tintColor = UIColor.appWhiteColor
        }
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
            
            let reachabilityService: ReachabilityService = this.locator.getService()
            guard reachabilityService.isReachable() else {
                AlertService.simpleAlert("No internet connection")
                this.tableView.pullToRefreshView.stopAnimating()

                return
            }
                
            postService.loadPosts(this.user) { objects, error in
                if let objects = objects {
                    this.postAdapter.update(withPosts: objects, action: .Reload)
                } else if let error = error {
                    print(error)
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
                    print(error)
                }
                this.tableView.infiniteScrollingView.stopAnimating()
            }
        }
    }
    
    // MARK: - IBActions
    @IBAction private func profileSettings() {
        let storyboard = UIStoryboard(name: Constants.Storyboard.Profile, bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier(Constants.EditProfile.EditProfileControllerIdentifier)
        navigationController!.showViewController(viewController, sender: self)
    }
    
}

extension ProfileViewController: PostAdapterDelegate {
    
    func showUserProfile(user: User) {
        
    }
    
    func showPlaceholderForEmptyDataSet() {
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
