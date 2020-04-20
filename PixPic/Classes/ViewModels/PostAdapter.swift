//
//  PostDataSource.swift
//  PixPic
//
//  Created by Jack Lapin on 17.01.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

public enum UpdateType {
    
    case reload, loadMore
    
}

@objc protocol PostAdapterDelegate: class {

    @objc optional func showUserProfile(_ adapter: PostAdapter, user: User)
    func showPlaceholderForEmptyDataSet(_ adapter: PostAdapter)
    func postAdapterRequestedViewUpdate(_ adapter: PostAdapter)
    func showSettingsMenu(_ adapter: PostAdapter, post: Post, index: Int, items: [AnyObject])

}

class PostAdapter: NSObject {

    fileprivate var posts = [Post]() {
        didSet {
            delegate?.showPlaceholderForEmptyDataSet(self)
            delegate?.postAdapterRequestedViewUpdate(self)
        }
    }

    weak var delegate: PostAdapterDelegate?
    fileprivate var locator: ServiceLocator

    init(locator: ServiceLocator) {
        self.locator = locator
    }

    var postQuantity: Int {
        return posts.count
    }

    func update(withPosts posts: [Post], action: UpdateType) {
        switch action {
        case .reload:
            self.posts.removeAll()

        default:
            break
        }

        self.posts.append(contentsOf: posts)
    }

    func getPost(atIndexPath indexPath: IndexPath) -> Post {
        let post = posts[indexPath.row]

        return post
    }

    func getPostIndexPath(_ postId: String) -> IndexPath? {
        for i in 0..<posts.count {
            if posts[i].objectId == postId {
                return IndexPath(row: i, section: 0)
            }
        }
        return nil
    }

    func removePost(atIndex index: Int) {
        posts.remove(at: index)
    }

}

extension PostAdapter: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postQuantity
    }

    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(
            PostViewCell.id,
            forIndexPath: indexPath
            ) as! PostViewCell
        let post = getPost(atIndexPath: indexPath as IndexPath)
        cell.configure(with: post, locator: locator)

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
