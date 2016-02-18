//
//  ProfileViewController.swift
//  P-effect
//
//  Created by Illya on 1/18/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import Toast

class ProfileViewController: UITableViewController {
    
    @IBOutlet weak var profileSettingsButton: UIBarButtonItem!
    @IBOutlet private weak var userAvatar: UIImageView!
    @IBOutlet private weak var userName: UILabel!
    @IBOutlet private weak var tableViewFooter: UIView!
    
    private var activityShown: Bool?
    private lazy var dataSource = PostAdapter()

    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupController()
        setupLoadersCallback()
    }
    
    // MARK: - Inner func
    private func setupController() {
//        dataSource = PostDataSource()
        showToast()
        tableView.dataSource = dataSource
        tableView.registerNib(PostViewCell.nib, forCellReuseIdentifier: PostViewCell.identifier)
        userAvatar.layer.cornerRadius = Constants.Profile.AvatarImageCornerRadius
        setupTableViewFooter()
        applyUser()
        if (user!.userIsCurrentUser()) {
            profileSettingsButton.enabled = true
            profileSettingsButton.image = UIImage(named: Constants.Profile.SettingsButtonImage)
            profileSettingsButton.tintColor = UIColor.whiteColor()
        }
    }
    
    private func setupTableViewFooter() {
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
    
    private func applyUser() {
        userAvatar.image = UIImage(named: Constants.Profile.AvatarImagePlaceholderName)
        userName.text = user?.username
        navigationItem.title = Constants.Profile.NavigationTitle
        user?.userAvatar { [weak self] image, error in
            if error == nil {
                self?.userAvatar.image = image
            } else {
                self?.view.makeToast(error?.localizedDescription)
            }
        }
    }
    
    private func showToast() {
        view.showToastActivityOn(view, duration: Constants.Profile.ToastActivityDuration)
        activityShown = true
    }
    
    private func setupLoadersCallback() {
        tableView.addPullToRefreshWithActionHandler { [weak self] in
            guard ReachabilityHelper.checkConnection() else {
                self?.tableView?.pullToRefreshView.stopAnimating()
                
                return
            }
    //        self?.dataSource?.fetchData(self?.model.user)
        }
        tableView.addInfiniteScrollingWithActionHandler { [weak self] in
      //      self?.dataSource?.fetchPagedData(self?.model.user)
        }
    }
    
    // MARK: - IBActions
    @IBAction func profileSettings(sender: AnyObject) {
        let board = UIStoryboard(name: "Main", bundle: nil)
        let controllerIdentifier = "EditProfileViewController"
        let viewController = board.instantiateViewControllerWithIdentifier(controllerIdentifier)
        navigationController!.showViewController(viewController, sender: self)
    }
    
}

extension ProfileViewController {
    
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
    
}
