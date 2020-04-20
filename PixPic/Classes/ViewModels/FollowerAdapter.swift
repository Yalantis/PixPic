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

    func followerAdapterRequestedViewUpdate(_ adapter: FollowerAdapter)

}

class FollowerAdapter: NSObject {

    weak var delegate: FollowerAdapterDelegate?

    fileprivate var followers = [User]() {
        didSet {
            delegate?.followerAdapterRequestedViewUpdate(self)
        }
    }

    var followersQuantity: Int {
        return followers.count
    }

    func getFollower(atIndexPath indexPath: IndexPath) -> User {
        return followers[indexPath.row]
    }

    func update(withFollowers followers: [User], action: UpdateType) {
        switch action {
        case .reload:
            self.followers.removeAll()

        default:
            break
        }

        self.followers.append(contentsOf: followers)
    }

}

extension FollowerAdapter: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followersQuantity
    }

    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(
            FollowerViewCell.id,
            forIndexPath: indexPath
            ) as! FollowerViewCell
        let follower = getFollower(atIndexPath: indexPath as IndexPath)
        cell.configure(withFollower: follower)

        return cell
    }

}
