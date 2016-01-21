//
//  ProfileViewController.swift
//  P-effect
//
//  Created by Illya on 1/18/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class ProfileViewController: UITableViewController {
    
    @IBOutlet weak var profileSettingsButton: UIBarButtonItem!
    @IBOutlet private weak var userAvatar: UIImageView!
    @IBOutlet private weak var userName: UILabel!
    @IBOutlet private weak var tableViewFooter: UIView!
    
    private var activityShown: Bool?
    private var dataSource: PostDataSource? {
        didSet {
            dataSource?.tableView = tableView
            dataSource?.fetchData(model.user)
            dataSource?.shouldPullToRefreshHandle = true
        }
    }
    var model: ProfileViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
        setupLoadersCallback()
    }

    // MARK: - Inner func 
    func setupController() {
        dataSource = PostDataSource()
        showToast()
        tableView.dataSource = dataSource
        tableView.registerNib(PostViewCell.nib, forCellReuseIdentifier: kPostViewCellIdentifier)
        userAvatar.layer.cornerRadius = Constants.Profile.AvatarImageCornerRadius
        setupTableViewFooter()
        applyUser()
        if (model!.userIsCurrentUser()) {
            profileSettingsButton.enabled = true
        }
    }
    
    func setupTableViewFooter() {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        var frame: CGRect = tableViewFooter.frame
        frame.size.height = (screenSize.height - Constants.Profile.HeaderHeight - (navigationController?.navigationBar.frame.size.height)!)
        tableViewFooter.frame = frame
        tableView.tableFooterView = tableViewFooter;
    }
    
    func applyUser() {
        userAvatar.image = UIImage(named: Constants.Profile.AvatarImagePlaceholderName)
        userName.text = model?.userName
        navigationItem.title = model?.userName
        model?.userAvatar({[weak self] (image, error) -> () in
            if error == nil {
                self?.userAvatar.image = image
            } else {
                self?.view.makeToast(error?.localizedDescription)
            }
        })
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
        if self.respondsToSelector(Selector("automaticallyAdjustsScrollViewInsets")) {
            self.automaticallyAdjustsScrollViewInsets = false
            var insets = tableView.contentInset
            insets.top = (navigationController?.navigationBar.bounds.size.height)! +
                UIApplication.sharedApplication().statusBarFrame.size.height
            tableView.contentInset = insets
            tableView.scrollIndicatorInsets = insets
        }
        tableView.addPullToRefreshWithActionHandler {
            [weak self] () -> () in
            self?.dataSource?.fetchData(self?.model.user)
        }
        tableView.addInfiniteScrollingWithActionHandler {
            [weak self]() -> () in
            self?.dataSource?.fetchPagedData(self?.model.user)
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
    
    // MARK: - IBActions
    @IBAction func profileSettings(sender: AnyObject) {
        let controller = storyboard!.instantiateViewControllerWithIdentifier("EditProfileViewController") as! EditProfileViewController
        self.navigationController?.showViewController(controller, sender: self)
    }

}
