//
//  ProfileViewController.swift
//  P-effect
//
//  Created by Illya on 1/18/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class ProfileViewController: UITableViewController {
    
    var user: User?
    
    @IBOutlet private weak var userAvatar: UIImageView!
    @IBOutlet private weak var userName: UILabel!
    @IBOutlet private weak var tableViewFooter: UIView!
    var dataSource: PostDataSource? {
        didSet {
            dataSource?.tableView = tableView
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
    }

    // MARK: - Inner func 
    func setupController() {
        userAvatar.layer.cornerRadius = Constants.Profile.AvatarImageCornerRadius
        tableView.dataSource = dataSource
        setupTableViewFooter()
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
    
    // MARK: - IBActions
    @IBAction func profileSettings(sender: AnyObject) {
        
    }

}
