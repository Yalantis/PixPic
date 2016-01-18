//
//  FeedViewController.swift
//  P-effect
//
//  Created by anna on 1/18/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

private let kReuseIdentifier = "PostViewCellIdentifier"

class FeedViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }

    @IBAction func userProfileButtonTapped(sender: AnyObject) {
        
    }
    
    private func setupTableView() {
        tableView.registerNib(PostViewCell.nib, forCellReuseIdentifier: kReuseIdentifier)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kReuseIdentifier) as! PostViewCell
        return cell
    }

}