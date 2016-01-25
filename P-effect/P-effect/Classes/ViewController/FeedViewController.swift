//
//  FeedViewController.swift
//  P-effect
//
//  Created by anna on 1/18/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

let kPostViewCellIdentifier = "PostViewCellIdentifier"
let kTopCellBarHeight: CGFloat = 48.0

class FeedViewController: UIViewController {
    
    private lazy var photoGenerator = PhotoGenerator()
    private lazy var postImageView = UIImageView()
    
    @IBOutlet weak var tableView: UITableView!
    private var activityShown: Bool?

    var postDataSource: PostDataSource? {
        didSet {
            postDataSource?.tableView = tableView
            postDataSource?.fetchData(nil)
            postDataSource?.delegate = self
            postDataSource?.shouldPullToRefreshHandle = true
        }
    }

    //MARK: - photo editor
    @IBAction func choosePhoto(sender: AnyObject) {
        if PFAnonymousUtils.isLinkedWithUser(PFUser.currentUser()) {
            let controller = storyboard!.instantiateViewControllerWithIdentifier("AuthorizationViewController") as! AuthorizationViewController
            navigationController?.pushViewController(controller, animated: true)
            return
        }
        photoGenerator.completionImageReceived = { [weak self] selectedImage in
            self?.handlePhotoSelected(selectedImage)
        }
        photoGenerator.showInView(self)
    }
    
    private func handlePhotoSelected(image: UIImage) {
        setSelectedPhoto(image)
    }
    
    func setSelectedPhoto(image: UIImage) {
        postImageView.image = image
        let pictureData = UIImageJPEGRepresentation(image, 0.5)
        if let file = PFFile(name: "image", data: pictureData!) {
            let saver = SaverService()
            saver.saveAndUploadPost(file, comment: nil)
        }
    }
    
    //MARK: - lifesicle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupDataSource()
        setupLoadersCallback()
        setupPlaceholderForEmptyDataSet()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.registerNib(PostViewCell.nib, forCellReuseIdentifier: kPostViewCellIdentifier)
    }
    
    private func setupDataSource() {
        postDataSource = PostDataSource()
        view.makeToastActivity(CSToastPositionCenter)
        
        activityShown = true

        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
            self?.view.hideToastActivity()
        }
        tableView.dataSource = postDataSource
    }
    
    private func setupPlaceholderForEmptyDataSet() {
        tableView.emptyDataSetDelegate = self
        tableView.emptyDataSetSource = self
    }
    
    @IBAction private func profileButtonTapped(sender: AnyObject) {
        
        if let currentUser = PFUser.currentUser() {
            if PFAnonymousUtils.isLinkedWithUser(currentUser) {
                let controller = storyboard!.instantiateViewControllerWithIdentifier("AuthorizationViewController") as! AuthorizationViewController
                navigationController?.pushViewController(controller, animated: true)

            } else {
                let controller = storyboard!.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
                controller.model = ProfileViewModel.init(profileUser: (currentUser as? User)!)
                self.navigationController?.showViewController(controller, sender: self)
            }
        } else {
            //TODO: if it's required to check "if let currentUser = PFUser.currentUser()" (we've created it during the app initialization)
        }
    }
    
    //MARK: - UserInteractive
    
    private func setupLoadersCallback() {
        if self.respondsToSelector(Selector("automaticallyAdjustsScrollViewInsets")) {
            self.automaticallyAdjustsScrollViewInsets = false
            var insets = tableView.contentInset
            insets.top = (navigationController?.navigationBar.bounds.size.height)! +
                UIApplication.sharedApplication().statusBarFrame.size.height
            tableView.contentInset = insets
            tableView.scrollIndicatorInsets = insets
        }
        tableView.addPullToRefreshWithActionHandler {
            [weak self] () -> () in
            self?.postDataSource?.fetchData(nil)
        }
        tableView.addInfiniteScrollingWithActionHandler {
            [weak self]() -> () in
            self?.postDataSource?.fetchPagedData(nil)
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
        var text = ""
        if postDataSource?.countOfModels() == 0 {
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
                text = "No data is currently available"
            }
//            text = "No data is currently available"
        }

        let attributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(20),
            NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        var text = ""
        
        if postDataSource?.countOfModels() == 0 {
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
                text = "No data is currently available"
            }
//            text = "Please pull down to refresh"
        }
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineBreakMode = .ByWordWrapping
        paragraph.alignment = .Center
        
        let attributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(15),
            NSForegroundColorAttributeName: UIColor.lightGrayColor(),
            NSParagraphStyleAttributeName: paragraph]
        
        return NSAttributedString(string: text, attributes: attributes)
    }

}

extension FeedViewController: UITableViewDelegate {

    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.bounds.width + kTopCellBarHeight
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.bounds.width + kTopCellBarHeight
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if (activityShown == true) {
            view.hideToastActivity()
            tableView.tableFooterView = nil
            tableView.scrollEnabled = true
        }
    }
    
}

extension FeedViewController: PostDataSourceDelegate {
    
    func showUserProfile(user: User) {
        let controller = storyboard!.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
        controller.model = ProfileViewModel.init(profileUser: user)
        self.navigationController?.showViewController(controller, sender: self)
    }
}