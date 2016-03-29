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

final class FeedViewController: UIViewController, StoryboardInitable {
    
    static let storyboardName = Constants.Storyboard.Feed
    
    private var router: protocol<AlertManagerDelegate, ProfilePresenter, PhotoEditorPresenter, AuthorizationPresenter, FeedPresenter, SettingsPresenter>!
    private weak var locator: ServiceLocator!
    
    private lazy var photoGenerator = PhotoGenerator()
    private lazy var settingsMenu = SettingsMenu()
    private lazy var postAdapter = PostAdapter()
    private var toolBar: FeedToolBar!
    
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.makeToastActivity(CSToastPositionCenter)
        setupTableView()
        setupToolBar()
        setupAdapter()
        setupObserver()
        setupLoadersCallback()
        
        let reachabilityService: ReachabilityService = locator.getService()
        if !reachabilityService.isReachable() {
            ExceptionHandler.handle(Exception.NoConnection)
            setupPlaceholderForEmptyDataSet()
            view.hideToastActivity()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        AlertManager.sharedInstance.registerAlertListener(router)
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
    func setLocator(locator: ServiceLocator) {
        self.locator = locator
    }
    
    func setRouter(router: FeedRouter) {
        self.router = router
    }
    
    private func setupToolBar() {
        toolBar = FeedToolBar.loadFromNibNamed(String(FeedToolBar))
        toolBar.didSelectPhoto = { [weak self] in
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
        
        let postService: PostService = locator.getService()
        postService.loadPosts { [weak self] objects, error in
            if let objects = objects {
                self?.postAdapter.update(withPosts: objects, action: .Reload)
            } else if let error = error {
                log.debug(error.localizedDescription)
            }
        }
    }
    
    private func setupPlaceholderForEmptyDataSet() {
        tableView?.emptyDataSetDelegate = self
        tableView?.emptyDataSetSource = self
    }
    
    // MARK: - photo editor
    private func choosePhoto() {
        if User.notAuthorized {
            router.showAuthorization()
            
            return
        }
        photoGenerator.completionImageReceived = { [weak self] selectedImage in
            self?.handlePhotoSelected(selectedImage)
        }
        photoGenerator.showInViewController(self)
    }
    
    private func handlePhotoSelected(image: UIImage) {
        router.showPhotoEditor(image)
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
                log.debug(error.localizedDescription)
                
                return
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
        
        if User.notAuthorized {
            router.showAuthorization()
        } else if let currentUser = currentUser {
            router.showProfile(currentUser)
        }
    }
    
    @IBAction func presentSettings(sender: AnyObject) {
        router.showSettings()
    }
    
    // MARK: - UserInteractive
    private func setupLoadersCallback() {
        let postService: PostService = locator.getService()
        tableView.addPullToRefreshWithActionHandler { [weak self] in
            guard let this = self else {
                return
            }

            let reachabilityService: ReachabilityService = this.locator.getService()
            guard reachabilityService.isReachable() else {
                ExceptionHandler.handle(Exception.NoConnection)
                this.tableView.pullToRefreshView.stopAnimating()
                
                return
            }
            postService.loadPosts { objects, error in
                if let objects = objects {
                    this.postAdapter.update(withPosts: objects, action: .Reload)
                    this.scrollToFirstRow()
                    AttributesCache.sharedCache.clear()
                } else if let error = error {
                    log.debug(error.localizedDescription)
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
                    log.debug(error.localizedDescription)
                }
                this.tableView.infiniteScrollingView.stopAnimating()
            }
        }
    }
    
}

extension FeedViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.bounds.size.width + PostViewCell.designedHeight
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        view.hideToastActivity()
    }
    
}

extension FeedViewController: PostAdapterDelegate {
    
    func showSettingsMenu(adapter: PostAdapter, post: Post, index: Int, items: [AnyObject]) {
        settingsMenu.showInViewController(self, forPost: post, atIndex: index, items: items)
        settingsMenu.completionAuthorizeUser = { [weak self] in
            self?.router.showAuthorization()
        }
        
        settingsMenu.completionRemovePost = { [weak self] index in
            guard let this = self else {
                return
            }
            this.postAdapter.removePost(atIndex: index)
            this.tableView.reloadData()
        }
    }

    func showUserProfile(adapter: PostAdapter, user: User) {
         router.showProfile(user)
    }
    
    func showPlaceholderForEmptyDataSet(adapter: PostAdapter) {
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
 
extension FeedViewController: NavigationControllerAppearanceContext {
    
    func preferredNavigationControllerAppearance(navigationController: UINavigationController) -> Appearance? {
        return Appearance()
    }

}
