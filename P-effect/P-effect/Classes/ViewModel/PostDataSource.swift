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
            tableView?.hideToastActivity()
            if countOfModels() == 0 {
                setupPlaceholderForEmptyDataSet()
            }
            tableView?.reloadData()
        }
    }
    
    var tableView: UITableView? {
        didSet {
            tableView?.makeToastActivity(CSToastPositionCenter)
        }
    }
    
    var shouldPullToRefreshHandle: Bool?
    
    private let loader = LoaderService()
    weak var delegate: PostDataSourceDelegate?
    
    override init() {
        super.init()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "fetchData", name: Constants.NotificationKey.NewPostUploaded, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private func setupPlaceholderForEmptyDataSet() {
        tableView?.emptyDataSetDelegate = self
        tableView?.emptyDataSetSource = self
    }
    
    @objc func fetchData(user: User?) {
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
    
    @objc func fetchPagedData(user: User?) {
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

extension PostDataSource: DZNEmptyDataSetDelegate {
    
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
}

extension PostDataSource: DZNEmptyDataSetSource {
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "No data is currently available"
        
        let attributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(20),
            NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let text = "Please pull down to refresh"
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .ByWordWrapping
        paragraph.alignment = .Center
        
        let attributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(15),
            NSForegroundColorAttributeName: UIColor.lightGrayColor(),
            NSParagraphStyleAttributeName: paragraph]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
}