 //
 //  FeedViewController.swift
 //  PixPic
 //
 //  Created by anna on 1/18/16.
 //  Copyright © 2016 Yalantis. All rights reserved.
 //
 
 import Foundation
 import UIKit
 import DZNEmptyDataSet
 import Toast
 
 typealias FeedRouterInterface = protocol<ProfilePresenter, PhotoEditorPresenter, AuthorizationPresenter, SettingsPresenter, FeedPresenter, AlertManagerDelegate>
 
 private let titleForEmptyData = NSLocalizedString("no_data_available", comment: "")
 private let descriptionForEmptyData = NSLocalizedString("pull_to_refresh", comment: "")
 
 final class FeedViewController: UIViewController, StoryboardInitiable {
    
    static let storyboardName = Constants.Storyboard.Feed
    
    private var router: FeedRouterInterface!
    private weak var locator: ServiceLocator!
    
    private lazy var photoProvider = PhotoProvider()
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
        
        if ReachabilityHelper.isReachable() {
            ExceptionHandler.handle(Exception.NoConnection)
            setupPlaceholderForEmptyDataSet()
            loadStickers()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        AlertManager.sharedInstance.setAlertDelegate(router)
        tableView.reloadData()
        
        if let subviews = navigationController?.navigationBar.subviews {
            for view in subviews {
                view.exclusiveTouch = true
            }
        }
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
    
    func setRouter(router: FeedRouterInterface) {
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
        tableView.registerNib(PostViewCell.cellNib, forCellReuseIdentifier: PostViewCell.id)
    }
    
    private func setupObserver() {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(FeedViewController.fetchDataFromNotification),
            name: Constants.NotificationName.NewPostIsUploaded,
            object: nil
        )
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(fetchDataFromNotification),
            name: Constants.NotificationName.NewPostIsReceaved,
            object: nil
        )
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(fetchDataFromNotification),
            name: Constants.NotificationName.FollowersListIsUpdated,
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
    }
    
    private func loadStickers() {        
        let stickersService: StickersLoaderService = locator.getService()
        stickersService.loadStickers()
    }
    
    
    // MARK: - photo editor
    private func choosePhoto() {
        if User.notAuthorized {
            router.showAuthorization()
            
            return
        }
        photoProvider.didSelectPhoto = { [weak self] selectedImage in
            self?.handlePhotoSelected(selectedImage)
        }
        photoProvider.presentPhotoOptionsDialog(in: self)
    }
    
    private func handlePhotoSelected(image: UIImage) {
        router.showPhotoEditor(image)
    }
    
    // MARK: - Notification handling
    @objc func fetchDataFromNotification() {
        let postService: PostService = locator.getService()
        postService.loadPosts { [weak self] objects, error in
            guard let this = self else {
                return
            }
            this.view.hideToastActivity()
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
    
    // MARK: - IBActions
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
            let noConnection = {
                ExceptionHandler.handle(Exception.NoConnection)
                this.tableView.pullToRefreshView.stopAnimating()
                
                return
            }
            var timeoutTimer = NSTimer.scheduledTimerWithTimeInterval(Constants.Network.TimeoutTimeInterval, repeats: false) {
                noConnection()
            }
            
            guard ReachabilityHelper.isReachable() else {
                noConnection()
                
                return
            }
            postService.loadPosts { objects, error in
                timeoutTimer.invalidate()
                timeoutTimer = nil
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
 
 // MARK: - UITableViewDelegate methods
 extension FeedViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.frame.width + PostViewCell.designedHeight
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        view.hideToastActivity()
    }
    
 }
 
 // MARK: - PostAdapterDelegate methods
 extension FeedViewController: PostAdapterDelegate {
    
    func showSettingsMenu(adapter: PostAdapter, post: Post, index: Int, items: [AnyObject]) {
        settingsMenu.locator = locator
        settingsMenu.showInViewController(self, forPost: post, atIndex: index, items: items)
        settingsMenu.userAuthorizationHandler = { [weak self] in
            self?.router.showAuthorization()
        }
        
        settingsMenu.postRemovalHandler = { [weak self] index in
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
 
 // MARK: - DZNEmptyDataSetDelegate methods
 extension FeedViewController: DZNEmptyDataSetDelegate {
    
    func emptyDataSetShouldAllowScroll(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
 }
 
 // MARK: - NavigationControllerAppearanceContext methods
 extension FeedViewController: NavigationControllerAppearanceContext {
    
    func preferredNavigationControllerAppearance(navigationController: UINavigationController) -> Appearance? {
        var appearance = Appearance()
        appearance.title = Constants.Feed.NavigationTitle
        return appearance
    }
    
 }
