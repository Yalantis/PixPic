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
    }
    
}