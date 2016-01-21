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
}

class PostDataSource: NSObject {
    
    private var arrayOfPosts: [Post] = [Post]() {
        didSet {
            tableView?.reloadData()
        }
    }
    var shouldPullToRefreshHandle: Bool?
    var tableView: UITableView?
    private let loader = LoaderService()
    weak var delegate: PostDataSourceDelegate?
    
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "fetchData", name: Constants.NotificationKey.NewPostUploaded, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @objc func fetchData(user: User?) {
        loader.loadData(user) {
            [weak self] (objects: [Post]?, error: NSError?) in
            if self?.shouldPullToRefreshHandle == true {
                self?.tableView?.pullToRefreshView.stopAnimating()
            }
            if let objects = objects {
                self?.arrayOfPosts = objects
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
        let cell = tableView.dequeueReusableCellWithIdentifier(kPostViewCellIdentifier, forIndexPath: indexPath) as! PostViewCell
        cell.delegate = self
        cell.post = modelAtIndex(indexPath)
   
        return cell
    }
    
}

extension PostDataSource: PostViewCellDelegate {
    
    func didChooseCellWithUser(user: User) {
        delegate?.showUserProfile(user)
    }
    
}



