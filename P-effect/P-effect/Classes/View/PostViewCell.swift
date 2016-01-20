//
//  PostViewCell.swift
//  P-effect
//
//  Created by anna on 1/18/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class PostViewCell: UITableViewCell {
    
    @IBOutlet private weak var postImageView: UIImageView!
    @IBOutlet private weak var profileImageView: UIImageView!
    
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var profileLabel: UILabel!
    
    let imageLoader = ImageLoaderService()
    
    var post: Post? {
        didSet {
            setContent()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.userInteractionEnabled = true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: "profileTapped:")
        profileImageView.addGestureRecognizer(imageGestureRecognizer)
        
        profileLabel.userInteractionEnabled = true
        let labelGestureRecognizer = UITapGestureRecognizer(target: self, action: "profileTapped:")
        profileLabel.addGestureRecognizer(labelGestureRecognizer)
        
        self.profileImageView.clipsToBounds = true
        self.postImageView.clipsToBounds = true
        
    }

    private func setContent() {
        dateLabel.text = String(post?.createdAt)
        
        imageLoader.getImageForContentItem(post?.image) { [weak self] image, error in
            if let error = error {
                print("\(error)")
            } else {
                self?.postImageView.image = image
            }
        }
        
        profileImageView.image = UIImage(named: "user_male_50")

        let user = post?.user
        if let user = user {
            profileLabel.text = user.username
            
            imageLoader.getImageForContentItem(user.avatar) { [weak self] image, error in
                if error == nil && image != nil {
                    self?.profileImageView.layer.cornerRadius = (self?.profileImageView.frame.size.width)! / 2
                    self?.profileImageView.clipsToBounds = true
                    self?.profileImageView.layer.borderWidth = 3.0
                    self?.profileImageView.layer.borderColor = UIColor.whiteColor().CGColor
                    self?.profileImageView.image = image
                } else if  error == nil && image == nil {
                    self?.profileImageView.image = UIImage(named: "user_male_50")

                } else  {
                    print("\(error)")
                }
            }
        }
    }
    
    static var nib: UINib? {
        let nib = UINib(nibName: String(self), bundle: nil)
        return nib
    }
    
    private func profileTapped(recognizer: UIGestureRecognizer) {
        let board = UIStoryboard(name: "Main", bundle: nil)
        let controller = board.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
        controller.user = post?.user
        if let window = UIApplication.sharedApplication().delegate!.window! as UIWindow! {
            window.rootViewController = controller
        }
    }
    
}