//
//  ProfileViewController.swift
//  P-effect
//
//  Created by Illya on 1/18/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class ProfileViewController: UITableViewController {
    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var userName: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.userAvatar.layer.cornerRadius = Constants.Profile.AvatarImageCornerRadius
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.sectionFooterHeight = 0
    }
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 10
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        self.tableView.sectionFooterHeight = 0
        return UITableViewCell()
    }
    
//    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        return 0
//    }
    
    // MARK: - IBActions
    @IBAction func editProfile(sender: AnyObject) {
        User.logOut()
        
    }

}
