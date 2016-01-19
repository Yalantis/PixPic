//
//  FeedViewController.swift
//  P-effect
//
//  Created by anna on 1/18/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

let kReuseIdentifier = "PostViewCellIdentifier"

class FeedViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.registerNib(PostViewCell.nib, forCellReuseIdentifier: kReuseIdentifier)
    }
    
    @IBAction func profileButtonTapped(sender: AnyObject) {

        Router(rootViewController: self).showLogin()
        
//        let currentUser = User.currentUser()

//        if let currentUser = currentUser {
//            UserModel(aUser: currentUser).linkOrUnlinkFacebook({ (state, error) -> () in
//                if state == true {
//                    Router(rootViewController: self).showProfile()
//                } else {
//                    Router(rootViewController: self).showLogin()
//                }
//            })
//        }
    }
    
}