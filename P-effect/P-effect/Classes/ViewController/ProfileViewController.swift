//
//  ProfileViewController.swift
//  P-effect
//
//  Created by Illya on 1/18/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import Toast

final class ProfileViewController: UITableViewController, StoryboardInitable {
    
    internal static let storyboardName = Constants.Storyboard.Profile
    
    var model: ProfileViewModel!
    var router: ProfileRouter!
    
    private var activityShown: Bool?
    private lazy var dataSource = PostAdapter()
    
    @IBOutlet private weak var profileSettingsButton: UIBarButtonItem!
    @IBOutlet private weak var userAvatar: UIImageView!
    @IBOutlet private weak var userName: UILabel!
    @IBOutlet private weak var tableViewFooter: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupController()
        setupLoadersCallback()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        AlertService.sharedInstance.delegate = router
    }
    
    // MARK: - Inner func
    func setupController() {
        
        showToast()
        tableView.dataSource = dataSource
        tableView.registerNib(PostViewCell.nib, forCellReuseIdentifier: PostViewCell.identifier)
        userAvatar.layer.cornerRadius = Constants.Profile.AvatarImageCornerRadius
        setupTableViewFooter()
        applyUser()
        if (model!.userIsCurrentUser()) {
            profileSettingsButton.enabled = true
            profileSettingsButton.image = UIImage(named: Constants.Profile.SettingsButtonImage)
            profileSettingsButton.tintColor = UIColor.whiteColor()
        }
    }
    
    func setupTableViewFooter() {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        var frame: CGRect = tableViewFooter.frame
        if let navigationController = navigationController {
            frame.size.height = (screenSize.height - Constants.Profile.HeaderHeight - navigationController.navigationBar.frame.size.height)
        } else {
            frame.size.height = Constants.Profile.PossibleInsets
        }
        tableViewFooter.frame = frame
        tableView.tableFooterView = tableViewFooter;
    }
    
    func applyUser() {
        userAvatar.image = UIImage(named: Constants.Profile.AvatarImagePlaceholderName)
        userName.text = model?.userName
        navigationItem.title = Constants.Profile.NavigationTitle
        model?.userAvatar {[weak self] image, error in
            guard let this = self else {
                return
            }
            if error == nil {
                this.userAvatar.image = image
            } else {
                this.view.makeToast(error?.localizedDescription)
            }
        }
    }
    
    func showToast() {
        self.view.makeToastActivity(CSToastPositionCenter)
        activityShown = true
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
            self?.view.hideToastActivity()
        }
    }
    
    private func setupLoadersCallback() {
        tableView.addPullToRefreshWithActionHandler { [weak self] in
            guard ReachabilityHelper.checkConnection() else {
                self?.tableView?.pullToRefreshView.stopAnimating()
                
                return
            }
            //TODO: figure out this commented code
            //        self?.dataSource?.fetchData(self?.model.user)
        }
        tableView.addInfiniteScrollingWithActionHandler { [weak self] in
            //      self?.dataSource?.fetchPagedData(self?.model.user)
        }
    }
    // MARK: Delegate methods
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if (activityShown == true) {
            view.hideToastActivity()
            tableView.tableFooterView = nil
            tableView.scrollEnabled = true
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.bounds.size.width + PostViewCell.designedHeight
    }
    
    // MARK: - IBActions
    @IBAction func profileSettings(sender: AnyObject) {
        router.showEditProfile()
    }
    
}
