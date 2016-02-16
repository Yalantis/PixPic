//
//  PostDataSource.swift
//  P-effect
//
//  Created by Jack Lapin on 17.01.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

protocol PostAdapterDelegate: class {
    
    func showUserProfile(user: User)
    func showPlaceholderForEmptyDataSet()
    func postAdapterRequestedViewUpdate(adapter: PostAdapter)
    
}

class PostAdapter: NSObject {
    
    var isEmpty: Bool {
        get {
            return self.countOfModels() == 0
        }
    }
    
    var posts = [Post]() {
        didSet {
            delegate?.showPlaceholderForEmptyDataSet()
            delegate?.postAdapterRequestedViewUpdate(self)
        }
    }
    weak var delegate: PostAdapterDelegate?
    
    func countOfModels() -> Int {
        return posts.count
    }
    
    func modelAtIndex(indexPath: NSIndexPath) -> Post? {
        let model = posts[Int(indexPath.row)]
        return model
    }
    
}

extension PostAdapter: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return countOfModels()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(
            PostViewCell.identifier,
            forIndexPath: indexPath
            ) as! PostViewCell
        cell.delegate = self
        cell.configureWithPost(modelAtIndex(indexPath))
        cell.selectionClosure = {
            [weak self] cell in
            if let path = tableView.indexPathForCell(cell) {
                let model = self?.modelAtIndex(path)
                if let user = model?.user {
                    self?.delegate?.showUserProfile(user)
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
    
}