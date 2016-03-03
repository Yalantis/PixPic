//
//  PostDataSource.swift
//  P-effect
//
//  Created by Jack Lapin on 17.01.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

public enum UpdateType {
    
    case Reload, LoadMore
}

protocol PostAdapterDelegate: class {
    
    func showUserProfile(user: User)
    func showPlaceholderForEmptyDataSet()
    func postAdapterRequestedViewUpdate(adapter: PostAdapter)
    func showActivityController(items: [AnyObject])
    
}

class PostAdapter: NSObject {
    
    private var posts = [Post]() {
        didSet {
            delegate?.showPlaceholderForEmptyDataSet()
            delegate?.postAdapterRequestedViewUpdate(self)
        }
    }
    
    weak var delegate: PostAdapterDelegate?
    
    var postQuantity: Int {
        return posts.count
    }
    
    func update(withPosts posts: [Post], action: UpdateType) {
        switch action {
        case .Reload:
            self.posts.removeAll()
            
        default:
            break
        }
        
        self.posts.appendContentsOf(posts)
    }
    
    func getPost(atIndexPath indexPath: NSIndexPath) -> Post {
        let post = posts[indexPath.row]
        return post
    }
    
}

extension PostAdapter: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postQuantity
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(
            PostViewCell.identifier,
            forIndexPath: indexPath
            ) as! PostViewCell
        cell.delegate = self
        cell.configure(withPost: getPost(atIndexPath: indexPath))
        cell.didSelectUser = { [weak self] cell in
            guard let this = self else {
                return
            }
            if let path = tableView.indexPathForCell(cell) {
                let model = this.getPost(atIndexPath: path)
                if let user = model.user {
                    this.delegate?.showUserProfile(user)
                }
            }
        }
        return cell
    }
    
}

extension PostAdapter: PostViewCellDelegate {
    
    func didChooseCellWithUser(user: User) {
        delegate?.showUserProfile(user)
    }
    
    func didChooseCellToShare(items: [AnyObject]) {
        delegate?.showActivityController(items)
    }
    
}