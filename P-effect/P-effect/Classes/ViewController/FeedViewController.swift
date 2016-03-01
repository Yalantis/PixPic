//
//  FeedViewController.swift
//  P-effect
//
//  Created by anna on 1/18/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation
import UIKit
import DZNEmptyDataSet
import Toast

class FeedViewController: UIViewController {
    
    private lazy var photoGenerator = PhotoGenerator()
    private var toolBar: FeedToolBar!
    
    lazy var locator = ServiceLocator()
    
    @IBOutlet private weak var tableView: UITableView!
    
    private lazy var postAdapter = PostAdapter()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.makeToastActivity(CSToastPositionCenter)
        setupTableView()
        setupToolBar()
        setupAdapter()
        setupObserver()
        setupLoadersCallback()
        
        if ReachabilityHelper.checkConnection() == false {
            setupPlaceholderForEmptyDataSet()
            view.hideToastActivity()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        toolBar.animateButton(isLifting: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let pointY = view.frame.height - Constants.BaseDimensions.ToolBarHeight
        toolBar.frame = CGRectMake(
            0,
            pointY,
            view.frame.width,
            Constants.BaseDimensions.ToolBarHeight
        )
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        toolBar.animateButton(isLifting: false)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Setup methods
    private func setupToolBar() {
        toolBar = FeedToolBar.loadFromNibNamed(String(FeedToolBar))
        toolBar.selectionClosure = { [weak self] in
            self?.choosePhoto()
        }
        view.addSubview(toolBar)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.registerNib(PostViewCell.nib, forCellReuseIdentifier: PostViewCell.identifier)
    }
    
    private func setupObserver() {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "fetchDataFromNotification",
            name: Constants.NotificationName.NewPostUploaded,
            object: nil
        )
    }
    
    private func setupAdapter() {
        tableView.dataSource = postAdapter
        postAdapter.delegate = self
        
        locator.registerService(PostService())
        
        let postService: PostService = locator.getService()
        postService.loadPosts { [weak self] objects, error in
            if let objects = objects {
                self?.postAdapter.update(withPosts: objects, action: .Reload)
            } else if let error = error {
                print(error)
            }
        }
    }
    
    private func setupPlaceholderForEmptyDataSet() {
        tableView?.emptyDataSetDelegate = self
        tableView?.emptyDataSetSource = self
    }
    
    // MARK: - photo editor
    private func choosePhoto() {
        let isUserAbsent = PFUser.currentUser() == nil
        if PFAnonymousUtils.isLinkedWithUser(PFUser.currentUser()) || isUserAbsent {
            let storyboard = UIStoryboard(name: Constants.Storyboard.Authorization, bundle: nil)
            let controller = storyboard.instantiateViewControllerWithIdentifier("AuthorizationViewController") as! AuthorizationViewController
            navigationController!.pushViewController(controller, animated: true)
            return
        }
        photoGenerator.completionImageReceived = { [weak self] selectedImage in
            self?.handlePhotoSelected(selectedImage)
        }
        photoGenerator.showInView(self)
    }
    
    private func handlePhotoSelected(image: UIImage) {
        let storyboard = UIStoryboard(name: Constants.Storyboard.PhotoEditor, bundle: nil)
        let controllerIdentifier = "PhotoEditorController"
        let viewController = storyboard.instantiateViewControllerWithIdentifier(controllerIdentifier) as! PhotoEditorViewController
        viewController.model = PhotoEditorModel.init(image: image)
        navigationController!.pushViewController(viewController, animated: false)
    }
    
    // MARK: - Notification handling
    dynamic func fetchDataFromNotification() {
        let postService: PostService = locator.getService()
        postService.loadPosts { [weak self] objects, error in
            guard let this = self else {
                return
            }
            if let objects = objects {
                this.postAdapter.update(withPosts: objects, action: .Reload)
                this.scrollToFirstRow()
            } else if let error = error {
                print(error)
            }
            self?.tableView?.pullToRefreshView.stopAnimating()
        }
    }
    
    private func scrollToFirstRow() {
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
    }
    
    @IBAction private func profileButtonTapped(sender: AnyObject) {
        let currentUser = User.currentUser()
        let isUserAbsent = currentUser == nil
        
        if PFAnonymousUtils.isLinkedWithUser(currentUser) || isUserAbsent {
            let storyboard = UIStoryboard(name: Constants.Storyboard.Authorization, bundle: nil)
            let controller = storyboard.instantiateViewControllerWithIdentifier("AuthorizationViewController") as! AuthorizationViewController
            navigationController!.pushViewController(controller, animated: true)
        } else if let currentUser = currentUser {
            let storyboard = UIStoryboard(name: Constants.Storyboard.Profile, bundle: nil)
            let controller = storyboard.instantiateInitialViewController() as! ProfileViewController
            controller.user = currentUser
            self.navigationController!.showViewController(controller, sender: self)
        }
    }
    
    // MARK: - UserInteractive
    
    private func setupLoadersCallback() {
        let postService: PostService = locator.getService()
        tableView.addPullToRefreshWithActionHandler { [weak self] in
            guard let this = self else {
                return
            }
            guard ReachabilityHelper.checkConnection() else {
                this.tableView.pullToRefreshView.stopAnimating()
                return
            }
            postService.loadPosts { objects, error in
                if let objects = objects {
                    this.postAdapter.update(withPosts: objects, action: .Reload)
                    this.scrollToFirstRow()
                } else if let error = error {
                    print(error)
                }
                this.tableView.pullToRefreshView.stopAnimating()
            }
        }
        tableView.addInfiniteScrollingWithActionHandler { [weak self] in
            guard let this = self else {
                return
            }
            guard let offset = self?.postAdapter.postQuantity else {
                this.tableView.infiniteScrollingView.stopAnimating()
                return
            }
            postService.loadPagedPosts(offset: offset) { objects, error in
                if let objects = objects {
                    this.postAdapter.update(withPosts: objects, action: .LoadMore)
                } else if let error = error {
                    print(error)
                }
                this.tableView.infiniteScrollingView.stopAnimating()
            }
        }
    }
    
}

extension FeedViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.bounds.size.width + PostViewCell.designedHeight + 48
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        view.hideToastActivity()
    }
    
}

extension FeedViewController: PostAdapterDelegate {
    
    func showSettingsMenu(post: Post, index: Int) {
        if post.user == User.currentUser() && ReachabilityHelper.checkConnection() {
            
            let settingsMenu = UIAlertController(
                title: nil,
                message: nil,
                preferredStyle: .ActionSheet
            )
            
            let removeAction = UIAlertAction(title: "Remove post", style: .Default) { [weak self] _ in
                guard let this = self else {
                    return
                }
                let postService: PostService = this.locator.getService()
                postService.removePost(post) { succeeded, error in
                    if succeeded {
                        this.postAdapter.removePost(atIndex: index)
                        this.tableView.reloadData()

                        print("removePost")
                    } else {
                        if let error = error?.localizedDescription {
                            print(error)
                        }
                    }
                }
            }
            settingsMenu.addAction(removeAction)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) {  _ in
                print("cancelAction")
            }
            settingsMenu.addAction(cancelAction)
            
            presentViewController(settingsMenu, animated: true, completion: nil)
        }
    }
    
    func showUserProfile(user: User) {
        let storyboard = UIStoryboard(name: Constants.Storyboard.Profile, bundle: nil)
        let controller = storyboard.instantiateInitialViewController() as! ProfileViewController
        controller.user = user
        self.navigationController!.showViewController(controller, sender: self)
    }
    
    func showPlaceholderForEmptyDataSet() {
        if postAdapter.postQuantity == 0 {
            setupPlaceholderForEmptyDataSet()
            view.hideToastActivity()
            tableView.reloadData()
        }
    }
    
    func postAdapterRequestedViewUpdate(adapter: PostAdapter) {
        tableView.reloadData()
    }
}

extension FeedViewController: DZNEmptyDataSetDelegate {
    
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
}

extension FeedViewController: DZNEmptyDataSetSource {
    
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
