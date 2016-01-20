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
    private var dataSource: PostDataSource? {
        didSet {
            dataSource?.tableView = tableView
        }
    }
    var model: ProfileViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
    }

    // MARK: - Inner func 
    func setupController() {
        tableView.registerNib(PostViewCell.nib, forCellReuseIdentifier: kReuseIdentifier)
        userAvatar.layer.cornerRadius = Constants.Profile.AvatarImageCornerRadius
        setupTableViewFooter()
        applyUser()
        if (model!.userIsCurrentUser()) {
            profileSettingsButton.enabled = true
        }
        dataSource = PostDataSource()
        if let dataSource = dataSource {
            if (dataSource.countOfModels() > 0) {
            tableView.tableFooterView = nil
            tableView.scrollEnabled = true
            }
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
        model?.userAvatar({[weak self] (image, error) -> () in
            if error == nil {
                self?.userAvatar.image = image
            } else {
                self?.view.makeToast(error?.localizedDescription)
            }
        })
    }
    
    // MARK: - IBActions
    @IBAction func profileSettings(sender: AnyObject) {
        
    }

}
