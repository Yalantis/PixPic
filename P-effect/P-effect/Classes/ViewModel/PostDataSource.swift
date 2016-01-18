//
//  PostDataSource.swift
//  P-effect
//
//  Created by Jack Lapin on 17.01.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class PostDataSource: NSObject {

    
    private var arrayOfPosts: [Post] = [Post]() {
        didSet {
            tableView?.reloadData()
        }
    }
    var tableView: UITableView?
    let loader = LoaderService()
    
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "fetchData", name: Constants.NotificationKey.NewPostUploaded, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @objc func fetchData() {
        loader.loadData(nil) {
            [weak self] (objects: [Post]?, error: NSError?) in
            self?.tableView?.pullToRefreshView.stopAnimating()
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
        let cell = tableView.dequeueReusableCellWithIdentifier("FeedCell", forIndexPath: indexPath)
      //  TODO: - setup cell with model
      //  cell.model = modelAtIndex(indexPath)
        return cell
    }
}