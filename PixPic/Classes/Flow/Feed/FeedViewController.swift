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

 typealias FeedRouterInterface = ProfilePresenter & PhotoEditorPresenter & AuthorizationPresenter & SettingsPresenter & FeedPresenter & AlertManagerDelegate

 private let titleForEmptyData = NSLocalizedString("no_data_available", comment: "")
 private let descriptionForEmptyData = NSLocalizedString("pull_to_refresh", comment: "")

 final class FeedViewController: UIViewController, StoryboardInitiable {

    static let storyboardName = Constants.Storyboard.feed

    fileprivate var router: FeedRouterInterface!
    fileprivate weak var locator: ServiceLocator!

    fileprivate lazy var photoProvider = PhotoProvider()
    fileprivate lazy var settingsMenu = SettingsMenu()
    fileprivate lazy var postAdapter: PostAdapter = PostAdapter(locator: self.locator)
    fileprivate var toolBar: FeedToolBar!

    @IBOutlet fileprivate weak var tableView: UITableView!

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        AlertManager.sharedInstance.setAlertDelegate(router)
        tableView.reloadData()

        if let subviews = navigationController?.navigationBar.subviews {
            for view in subviews {
                view.isExclusiveTouch = true
            }
        }
        updateCurrentUserInfoIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        toolBar.animateButton(isLifting: true)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let pointY = view.frame.height - Constants.BaseDimensions.toolBarHeight
        toolBar.frame = CGRect(
            x: 0,
            y: pointY,
            width: view.frame.width,
            height: Constants.BaseDimensions.toolBarHeight
        )
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        toolBar.animateButton(isLifting: false)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup methods
    func setLocator(_ locator: ServiceLocator) {
        self.locator = locator
    }

    func setRouter(_ router: FeedRouterInterface) {
        self.router = router
    }

    fileprivate func setupToolBar() {
        toolBar = FeedToolBar.loadFromNibNamed(String(FeedToolBar))
        toolBar.didSelectPhoto = { [weak self] in
            self?.choosePhoto()
        }
        view.addSubview(toolBar)
    }

    fileprivate func setupTableView() {
        tableView.delegate = self
        tableView.registerNib(PostViewCell.cellNib, forCellReuseIdentifier: PostViewCell.id)
    }

    fileprivate func setupObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(FeedViewController.fetchDataFromNotification),
            name: NSNotification.Name(rawValue: Constants.NotificationName.newPostIsUploaded),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(fetchDataFromNotification),
            name: NSNotification.Name(rawValue: Constants.NotificationName.newPostIsReceaved),
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(fetchDataFromNotification),
            name: NSNotification.Name(rawValue: Constants.NotificationName.followersListIsUpdated),
            object: nil
        )
    }

    fileprivate func setupAdapter() {
        tableView.dataSource = postAdapter as! UITableViewDataSource
        postAdapter.delegate = self

        let postService: PostService = locator.getService()
        postService.loadPosts { [weak self] objects, error in
            if let objects = objects {
                self?.postAdapter.update(withPosts: objects, action: .reload)
            } else if let error = error {
                log.debug(error.localizedDescription)
            }
        }
    }

    fileprivate func setupPlaceholderForEmptyDataSet() {
        tableView?.emptyDataSetDelegate = self
    }

    fileprivate func loadStickers() {
        let stickersService: StickersLoaderService = locator.getService()
        stickersService.loadStickers()
    }


    // MARK: - photo editor
    fileprivate func choosePhoto() {
        if User.notAuthorized {
            router.showAuthorization()

            return
        }
        photoProvider.didSelectPhoto = { [weak self] selectedImage in
            self?.handlePhotoSelected(selectedImage)
        }
        photoProvider.presentPhotoOptionsDialog(in: self)
    }

    fileprivate func handlePhotoSelected(_ image: UIImage) {
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
                this.postAdapter.update(withPosts: objects, action: .reload)
                this.scrollToFirstRow()
            } else if let error = error {
                log.debug(error.localizedDescription)

                return
            }
            self?.tableView?.pullToRefreshView.stopAnimating()
        }
    }

    fileprivate func scrollToFirstRow() {
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }

    fileprivate func updateCurrentUserInfoIfNeeded() {
        if let currentUser = User.currentUser(), currentUser.facebookId == nil && !User.notAuthorized {
            let authenticationService: AuthenticationService = locator.getService()
            authenticationService.updateUserInfoViaFacebook(currentUser) { _, error in
                if let error = error {
                    ErrorHandler.handle(error)
                }
            }
        }
    }

    // MARK: - IBActions
    @IBAction fileprivate func profileButtonTapped(_ sender: AnyObject) {
        let currentUser = User.currentUser()

        if User.notAuthorized {
            router.showAuthorization()
        } else if let currentUser = currentUser {
            router.showProfile(currentUser)
        }
    }

    @IBAction func presentSettings(_ sender: AnyObject) {
        router.showSettings()
    }

    // MARK: - UserInteractive
    fileprivate func setupLoadersCallback() {
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
            var timeoutTimer = NSTimer.scheduledTimerWithTimeInterval(Constants.Network.timeoutTimeInterval, repeats: false) {
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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.width + PostViewCell.designedHeight
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        view.hideToastActivity()
    }

 }

 // MARK: - PostAdapterDelegate methods
 extension FeedViewController: PostAdapterDelegate {

    func showSettingsMenu(_ adapter: PostAdapter, post: Post, index: Int, items: [AnyObject]) {
        settingsMenu.locator = locator
        settingsMenu.showInViewController(self, forPost: post, atIndex: index, items: items)

        settingsMenu.postRemovalHandler = { [weak self] index in
            guard let this = self else {
                return
            }
            this.postAdapter.removePost(atIndex: index)
            this.tableView.reloadData()
        }
    }

    func showUserProfile(_ adapter: PostAdapter, user: User) {
        router.showProfile(user)
    }

    func showPlaceholderForEmptyDataSet(_ adapter: PostAdapter) {
        if postAdapter.postQuantity == 0 {
            setupPlaceholderForEmptyDataSet()
            view.hideToastActivity()
            tableView.reloadData()
        }
    }

    func postAdapterRequestedViewUpdate(_ adapter: PostAdapter) {
        tableView.reloadData()
    }

 }

 // MARK: - DZNEmptyDataSetDelegate methods
 extension FeedViewController: DZNEmptyDataSetDelegate {

    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }

 }

 // MARK: - NavigationControllerAppearanceContext methods
 extension FeedViewController: NavigationControllerAppearanceContext {

    func preferredNavigationControllerAppearance(_ navigationController: UINavigationController) -> Appearance? {
        var appearance = Appearance()
        appearance.title = Constants.Feed.navigationTitle
        return appearance
    }

 }
