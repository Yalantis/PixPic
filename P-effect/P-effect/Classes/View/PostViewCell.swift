//
//  PostViewCell.swift
//  P-effect
//
//  Created by anna on 1/18/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

protocol PostViewCellDelegate: class {
    
    func didChooseCellWithUser(user: User)
}

class PostViewCell: UITableViewCell {
    
    static var nib: UINib? {
        let nib = UINib(nibName: String(self), bundle: nil)
        return nib
    }
    
    private var postImageURL: String?
    private var avatarURL: String?
    
    @IBOutlet private weak var postImageView: UIImageView!
    @IBOutlet private weak var profileImageView: UIImageView!
    
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var profileLabel: UILabel!
    
    let imageLoader = ImageLoaderService()
    weak var delegate: PostViewCellDelegate?
    
    var post: Post? {
        didSet {
            setContent()
            postImageURL = post?.image.url
            avatarURL = post?.user?.avatar?.url
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: "profileTapped:")
        profileImageView.addGestureRecognizer(imageGestureRecognizer)
        
        let labelGestureRecognizer = UITapGestureRecognizer(target: self, action: "profileTapped:")
        profileLabel.addGestureRecognizer(labelGestureRecognizer)
        selectionStyle = .None
    }
    
    private func setContent() {
        dateLabel.text = MHPrettyDate.prettyDateFromDate(
            post?.createdAt,
            withFormat: MHPrettyDateShortRelativeTime
        )
        setPostImage()
        setAvatarImage()
    }
    
    private func setPostImage() {
        if post?.image.url != postImageURL {
            postImageView?.image = nil
            imageLoader.getImageForContentItem(post?.image) { [weak self] image, error in
                if let error = error {
                    print("\(error)")
                } else {
                    self?.postImageView.image = image
                }
            }
        }
    }
    
    private func setAvatarImage() {
        guard let user = post?.user else {
            profileImageView.image = UIImage(named: "user_male_50")
            return
        }
        profileLabel.text = user.username
        if avatarURL != post?.user?.avatar?.url {
            profileImageView.image = nil
            imageLoader.getImageForContentItem(user.avatar) { [weak self] image, error in
                if error == nil && image != nil {
                    self?.profileImageView.layer.cornerRadius = (self?.profileImageView.frame.size.width)! / 2
                    self?.profileImageView.image = image
                } else if  error == nil && image == nil {
                    self?.profileImageView.image = UIImage(named: "user_male_50")
                } else  {
                    print("\(error)")
                }
            }
        }
    }
    
    dynamic private func profileTapped(recognizer: UIGestureRecognizer) {
        delegate?.didChooseCellWithUser((post?.user)!)
    }
    
}