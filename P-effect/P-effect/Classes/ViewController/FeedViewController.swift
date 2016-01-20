//
//  FeedViewController.swift
//  P-effect
//
//  Created by anna on 1/18/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

let kReuseIdentifier = "PostViewCellIdentifier"

class FeedViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var dataSource: PostDataSource? {
        didSet {
            tableView!.dataSource = dataSource
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    private func setupTableView() {
        tableView.registerNib(PostViewCell.nib, forCellReuseIdentifier: kReuseIdentifier)
    }
    
    private func setupDataSource() {
        dataSource = PostDataSource()
        dataSource?.tableView = tableView
        dataSource?.fetchData()
    }
    
    @IBAction private func profileButtonTapped(sender: AnyObject) {
        
        if let currentUser = PFUser.currentUser() {
            if PFAnonymousUtils.isLinkedWithUser(currentUser) {
                Router.sharedRouter().showLogin(animated: true)
            } else {
                let controller = storyboard!.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
                controller.user = currentUser as? User
                navigationController?.pushViewController(controller, animated: true)
            }
        } else {
            //TODO: if it's required to check "if let currentUser = PFUser.currentUser()" (we've created it during the app initialization)
        }
    }
    
}