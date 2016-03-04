//
//  FollowerAdapter.swift
//  P-effect
//
//  Created by anna on 3/3/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class FollowerAdapter: NSObject {
    
    private var follovers = [User]()
    
    var folloversQuantity: Int {
        return follovers.count
    }
        
    func getFollover(atIndexPath indexPath: NSIndexPath) -> User {
        let follover = follovers[indexPath.row]
        return follover
    }

}

extension FollowerAdapter: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folloversQuantity
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(
            FollowerViewCell.identifier,
            forIndexPath: indexPath
            ) as! FollowerViewCell
        cell.configure(withFollower: getFollover(atIndexPath: indexPath))
        
        return cell
    }
    
}