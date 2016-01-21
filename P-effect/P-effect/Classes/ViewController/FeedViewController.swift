//
//  FeedViewController.swift
//  P-effect
//
//  Created by anna on 1/18/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

let kPostViewCellIdentifier = "PostViewCellIdentifier"

class FeedViewController: UIViewController {
    
    private lazy var photoGenerator = PhotoGenerator()
    private lazy var postImageView = UIImageView()
    
    @IBOutlet weak var tableView: UITableView!
    
    var postDataSource: PostDataSource? {
        didSet {
            postDataSource?.tableView = tableView
            postDataSource?.fetchData(nil)
            postDataSource?.shouldPullToRefreshHandle = true
            postDataSource?.delegate = self
        }
    }

    //MARK: - photo editor
    @IBAction func choosePhoto(sender: AnyObject) {
        if PFAnonymousUtils.isLinkedWithUser(User.currentUser()) {
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
    }
    
    private func setupTableView() {
        tableView.registerNib(PostViewCell.nib, forCellReuseIdentifier: kPostViewCellIdentifier)
    }
    
    private func setupDataSource() {
        postDataSource = PostDataSource()
        tableView.dataSource = postDataSource
    }
    
    @IBAction private func profileButtonTapped(sender: AnyObject) {
        
        if let currentUser = User.currentUser() {
            if PFAnonymousUtils.isLinkedWithUser(currentUser) {
                let controller = storyboard!.instantiateViewControllerWithIdentifier("AuthorizationViewController") as! AuthorizationViewController
                navigationController?.pushViewController(controller, animated: true)
            } else {
                let controller = storyboard!.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
                controller.model = ProfileViewModel.init(profileUser: currentUser as! User)
                self.navigationController?.showViewController(controller, sender: self)
            }
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

extension FeedViewController: PostDataSourceDelegate {
    
    func showUserProfile(user: User) {
        let controller = storyboard!.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
        controller.model = ProfileViewModel.init(profileUser: user)
        self.navigationController?.showViewController(controller, sender: self)
    }
    
}