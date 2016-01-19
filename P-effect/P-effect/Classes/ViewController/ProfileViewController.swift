//
//  ProfileViewController.swift
//  P-effect
//
//  Created by Illya on 1/18/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class ProfileViewController: UITableViewController {
    
    @IBOutlet private weak var userAvatar: UIImageView!
    @IBOutlet private weak var userName: UILabel!
    @IBOutlet private weak var tableViewFooter: UIView!
    private var dataSource: PostDataSource? {
        didSet {
            tableView!.dataSource = dataSource
        }
    }
    var userModel: UserModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
    }

    // MARK: - Inner func 
    func setupController() {
        userAvatar.layer.cornerRadius = Constants.Profile.AvatarImageCornerRadius
        tableView.registerNib(PostViewCell.nib, forCellReuseIdentifier: kReuseIdentifier)
        tableView.dataSource = dataSource
        setupTableViewFooter()
        applyUser()
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
        if let currentUser = User.currentUser() {
            userModel = UserModel(aUser: currentUser)
            userModel?.checkIfUsernameExists({ (completion) -> () in
                if completion {
                    self.userName.text = self.userModel?.user.username
                }
            })
            if let avatar = userModel?.user.avatar {
                avatar.getDataInBackgroundWithBlock {
                    (imageData: NSData?, error: NSError?) -> Void in
                    if error == nil {
                        if let imageData = imageData {
                            self.userAvatar.image = UIImage(data:imageData)
                        }
                    } else {
                        print(error)
                    }
                }
            }
        }
    }
    
    // MARK: - IBActions
    @IBAction func profileSettings(sender: AnyObject) {
        
    }

}
