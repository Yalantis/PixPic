//
//  PostDataSource.swift
//  PixPic
//
//  Created by Jack Lapin on 17.01.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

public enum UpdateType {
    case Reload, LoadMore
}

@objc protocol PostAdapterDelegate: class {
    
    optional func showUserProfile(adapter: PostAdapter, user: User)
    func showPlaceholderForEmptyDataSet(adapter: PostAdapter)
    func postAdapterRequestedViewUpdate(adapter: PostAdapter)
    func showSettingsMenu(adapter: PostAdapter, post: Post, index: Int, items: [AnyObject])
    
}

class PostAdapter: NSObject {
    
    private var posts = [Post]() {
        didSet {
            delegate?.showPlaceholderForEmptyDataSet(self)
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
    
    func removePost(atIndex index: Int) {
        posts.removeAtIndex(index)
    }
    
}

extension PostAdapter: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postQuantity
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(
            PostViewCell.id,
            forIndexPath: indexPath
            ) as! PostViewCell
        let post = getPost(atIndexPath: indexPath)
        cell.configure(withPost: post)
        
        cell.didSelectUser = { [weak self] cell in
            guard let this = self else {
                return
            }
            if let path = tableView.indexPathForCell(cell) {
                let post = this.getPost(atIndexPath: path)
                if let user = post.user {
                    this.delegate?.showUserProfile?(this, user: user)
                }
            }
        }
        
        cell.didSelectSettings = { [weak self] cell, items in
            guard let this = self else {
                return
            }
            if let path = tableView.indexPathForCell(cell) {
                let post = this.getPost(atIndexPath: path)
                this.delegate?.showSettingsMenu(this, post: post, index: path.row, items: items)
            }
        }
        
        return cell
    }
    
}
