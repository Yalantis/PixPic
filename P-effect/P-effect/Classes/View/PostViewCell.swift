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
    
    var post: Post! {
        didSet {
            setContent()
        }
    }
    
    private func setContent() {
        dateLabel.text = String(post.createdAt)
        
        imageLoader.getImageForContentItem(post.image) { [unowned self] image, error in
            if error == nil {
                self.postImageView.image = image
            } else {
                print("\(error)")
            }
        }
        
        let user = post.user
        if let user = user {
            profileLabel.text = user.username
            
            imageLoader.getImageForContentItem(user.avatar) { [unowned self] image, error in
                if error == nil {
                    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.width / 2
                    self.profileImageView.clipsToBounds = true
                    self.profileImageView.layer.borderWidth = 3.0
                    self.profileImageView.layer.borderColor = UIColor.whiteColor().CGColor
                    self.profileImageView.image = image
                } else {
                    print("\(error)")
                }
            }
        }

    }
    
    static var nib: UINib? {
        let nib = UINib(nibName: String(self), bundle: nil)
        return nib
    }
    
}