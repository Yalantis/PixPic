//
//  PostDataSource.swift
//  P-effect
//
//  Created by Jack Lapin on 17.01.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

protocol PostDataSourceDelegate: class {
    
    func showUserProfile(user: User)
    func showPlaceholderForEmptyDataSet()
    
}

class PostDataSource: NSObject {
    
    private var arrayOfPosts = [Post]() {
        didSet {
            tableView?.reloadData()
            delegate?.showPlaceholderForEmptyDataSet()
        }
    }
    
    var tableView: UITableView?
    var shouldPullToRefreshHandle = false
    
    private lazy var loader = LoaderService()
    weak var delegate: PostDataSourceDelegate?
    
    override init() {
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "fetchDataFromNotification",
            name: Constants.NotificationKey.NewPostUploaded,
            object: nil
        )
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    dynamic func fetchDataFromNotification() {
        fetchData(nil)
    }
    
    func fetchData(user: User?) {
        loader.loadFreshData(user) {
            [weak self] (objects: [Post]?, error: NSError?) in
            if self?.shouldPullToRefreshHandle == true {
                self?.tableView?.pullToRefreshView.stopAnimating()
            }
            if let objects = objects {
                self?.arrayOfPosts = objects
            }
            if let error = error {
                handleError(error)
            }
        }
    }
    
    dynamic func fetchPagedData(user: User?) {
        loader.loadPagedData(user, leap: countOfModels()) {
            [weak self] (objects: [Post]?, error: NSError?) in
            if let objects = objects {
                self?.tableView?.infiniteScrollingView.stopAnimating()
                self?.arrayOfPosts.appendContentsOf(objects)
            }
            if let error = error {
                handleError(error)
            }
        }
    }
    
    func countOfModels() -> Int {
        return arrayOfPosts.count
    }
    
    func modelAtIndex(indexPath: NSIndexPath) -> Post? {
        let model = arrayOfPosts[Int(indexPath.row)]
        return model
    }
    
}

extension PostDataSource: UITableViewDataSource {
    
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

extension PostDataSource: PostViewCellDelegate {
    
    func didChooseCellWithUser(user: User) {
        delegate?.showUserProfile(user)
    }
    
}