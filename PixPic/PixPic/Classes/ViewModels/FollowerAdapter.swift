//
//  FollowerAdapter.swift
//  PixPic
//
//  Created by anna on 3/3/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

enum FollowType: String {
    case Followers = "Followers"
    case Following = "Following"
}

protocol FollowerAdapterDelegate: class {
    
    func followerAdapterRequestedViewUpdate(adapter: FollowerAdapter)
    
}

class FollowerAdapter: NSObject {
    
    weak var delegate: FollowerAdapterDelegate?
    
    private var followers = [User]() {
        didSet {
            delegate?.followerAdapterRequestedViewUpdate(self)
        }
    }
    
    var followersQuantity: Int {
        return followers.count
    }
        
    func getFollower(atIndexPath indexPath: NSIndexPath) -> User {
        return followers[indexPath.row]
    }
    
    func update(withFollowers followers: [User], action: UpdateType) {
        switch action {
        case .Reload:
            self.followers.removeAll()
            
        default:
            break
        }
        
        self.followers.appendContentsOf(followers)
    }

}

extension FollowerAdapter: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followersQuantity
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(
            FollowerViewCell.id,
            forIndexPath: indexPath
            ) as! FollowerViewCell
        let follower = getFollower(atIndexPath: indexPath)
        cell.configure(withFollower: follower)
        
        return cell
    }
    
}