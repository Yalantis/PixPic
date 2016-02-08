//
//  FeedViewController.swift
//  P-effect
//
//  Created by anna on 1/18/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
import Toast

class FeedViewController: UIViewController {
    
    private lazy var photoGenerator = PhotoGenerator()
    private lazy var postImageView = UIImageView()
    private var toolBar: FeedToolBar!
    
    @IBOutlet private weak var tableView: UITableView!
    
    var postDataSource: PostDataSource? {
        didSet {
            postDataSource?.tableView = tableView
            postDataSource?.fetchData(nil)
            postDataSource?.delegate = self
            postDataSource?.shouldPullToRefreshHandle = true
        }
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.makeToastActivity(CSToastPositionCenter)
        setupTableView()
        setupDataSource()
        setupLoadersCallback()
        setupToolBar()
        
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
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        toolBar.animateButton(isLifting: false)
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
    
    private func setupToolBar() {
        toolBar = FeedToolBar.loadFromNibNamed(String(FeedToolBar))
        toolBar.selectionClosure = { [unowned self] in
            self.choosePhoto()
        }
        view.addSubview(toolBar)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.registerNib(PostViewCell.nib, forCellReuseIdentifier: PostViewCell.identifier)
    }
    
    private func setupDataSource() {
        postDataSource = PostDataSource()
        tableView.dataSource = postDataSource
    }
    
    private func setupPlaceholderForEmptyDataSet() {
        tableView?.emptyDataSetDelegate = self
        tableView?.emptyDataSetSource = self
    }
    
    //MARK: - photo editor
    private func choosePhoto() {
        let isUserAbsent = PFUser.currentUser() == nil
        if PFAnonymousUtils.isLinkedWithUser(PFUser.currentUser()) || isUserAbsent {
            let controller = storyboard!.instantiateViewControllerWithIdentifier("AuthorizationViewController") as! AuthorizationViewController
            navigationController!.pushViewController(controller, animated: true)
            return
        }
        photoGenerator.completionImageReceived = { [unowned self] selectedImage in
            self.handlePhotoSelected(selectedImage)
        }
        photoGenerator.showInView(self)
    }
    
    private func handlePhotoSelected(image: UIImage) {
        let board = UIStoryboard(name: "Main", bundle: nil)
        let controllerIdentifier = "PhotoEditorController"
        let viewController = board.instantiateViewControllerWithIdentifier(controllerIdentifier) as! PhotoEditorViewController
        viewController.model = PhotoEditorModel.init(image: image)
        navigationController!.pushViewController(viewController, animated: false)
    }
    
    func setSelectedPhoto(image: UIImage) {
        postImageView.image = image
        let pictureData = UIImageJPEGRepresentation(image, 0.5)
        if let file = PFFile(name: "image", data: pictureData!) {
            SaverService.saveAndUploadPost(file, comment: nil)
        }
    }
    
    @IBAction private func profileButtonTapped(sender: AnyObject) {
        
        if let currentUser = PFUser.currentUser() {
            if PFAnonymousUtils.isLinkedWithUser(currentUser) {
                let controller = storyboard!.instantiateViewControllerWithIdentifier("AuthorizationViewController") as! AuthorizationViewController
                navigationController!.pushViewController(controller, animated: true)
                
            } else {
                let controller = storyboard!.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
                controller.model = ProfileViewModel.init(profileUser: (currentUser as? User)!)
                self.navigationController!.showViewController(controller, sender: self)
            }
        } else {
            //TODO: if it's required to check "if let currentUser = PFUser.currentUser()" (we've created it during the app initialization)
        }
    }
    
    //MARK: - UserInteractive
    
    private func setupLoadersCallback() {
        tableView.addPullToRefreshWithActionHandler { [unowned self] () -> () in
            guard ReachabilityHelper.checkConnection() else {
                self.tableView?.pullToRefreshView.stopAnimating()
                return
            }
            self.postDataSource?.fetchData(nil)
        }
        tableView.addInfiniteScrollingWithActionHandler {
            [unowned self]() -> () in
            self.postDataSource?.fetchPagedData(nil)
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

extension FeedViewController: PostDataSourceDelegate {
    
    func showUserProfile(user: User) {
        let controller = storyboard!.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
        controller.model = ProfileViewModel.init(profileUser: user)
        self.navigationController!.showViewController(controller, sender: self)
    }
    
    func showPlaceholderForEmptyDataSet() {
        if postDataSource?.countOfModels() == 0 {
            setupPlaceholderForEmptyDataSet()
            view.hideToastActivity()
            tableView.reloadData()
        }
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