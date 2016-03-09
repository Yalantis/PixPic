//
//  FollowerAdapter.swift
//  P-effect
//
//  Created by anna on 3/3/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class FollowerAdapter: NSObject {
    
    private var followers = [User]()
    
    var followersQuantity: Int {
        return followers.count
    }
        
    func getFollower(atIndexPath indexPath: NSIndexPath) -> User {
        return followers[indexPath.row]
    }

}

extension FollowerAdapter: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followersQuantity
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(
            FollowerViewCell.identifier,
            forIndexPath: indexPath
            ) as! FollowerViewCell
        let follower = getFollower(atIndexPath: indexPath)
        cell.configure(withFollower: follower)
        
        return cell
    }
    
}