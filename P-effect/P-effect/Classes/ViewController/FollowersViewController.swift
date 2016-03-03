//
//  FollowersViewController.swift
//  P-effect
//
//  Created by anna on 3/3/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

final class FollowersViewController: UIViewController, StoryboardInitable {
    
    static let storyboardName = Constants.Storyboard.Profile

    var router: protocol<ProfilePresenter, AlertManagerDelegate>!
    
    private lazy var followerAdapter = FollowerAdapter()
    private weak var locator: ServiceLocator!

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupAdapter()
    }
    
    func setLocator(locator: ServiceLocator) {
        self.locator = locator
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.registerNib(FollowerViewCell.cellNib, forCellReuseIdentifier: FollowerViewCell.identifier)
    }
    
    private func setupAdapter() {
        tableView.dataSource = followerAdapter
    }
    
}

extension FollowersViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}
