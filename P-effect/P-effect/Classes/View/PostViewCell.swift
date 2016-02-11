//
//  PostViewCell.swift
//  P-effect
//
//  Created by anna on 1/18/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import SDWebImage
import MHPrettyDate

protocol PostViewCellDelegate: class {
    
    func didChooseCellWithUser(user: User)
}

class PostViewCell: UITableViewCell {
    
    static let identifier = "PostViewCellIdentifier"
    static let designedHeight: CGFloat = 78
    
    static var nib: UINib? {
        let nib = UINib(nibName: String(self), bundle: nil)
        return nib
    }
    
    @IBOutlet private weak var postImageView: UIImageView!
    @IBOutlet private weak var profileImageView: UIImageView!
    
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var profileLabel: UILabel!
    
    var selectionClosure: ((cell: PostViewCell) -> Void)?
    
    let imageLoader = ImageLoaderService()
    weak var delegate: PostViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: "profileTapped:")
        profileImageView.addGestureRecognizer(imageGestureRecognizer)
        
        let labelGestureRecognizer = UITapGestureRecognizer(target: self, action: "profileTapped:")
        profileLabel.addGestureRecognizer(labelGestureRecognizer)
        selectionStyle = .None
    }
    
    func configureWithPost(post: Post?) {
        guard let post = post else {
            profileImageView.image = UIImage.placeholderImage()
            profileImageView.image = UIImage.avatarPlaceholderImage()
            return
        }
        profileLabel.text = post.user?.username
        dateLabel.text = MHPrettyDate.prettyDateFromDate(
            post.createdAt,
            withFormat: MHPrettyDateShortRelativeTime
        )
        profileImageView.layer.cornerRadius = (profileImageView.frame.size.width) / 2
        postImageView.sd_setImageWithURL(
            NSURL(string: post.image.url!),
            placeholderImage: UIImage.placeholderImage(),
            completed: nil
        )
        guard let user = post.user else {
            profileImageView.image = UIImage.avatarPlaceholderImage()
            return
        }
        if let avatar = user.avatar?.url {
            profileImageView.sd_setImageWithURL(
                NSURL(string: avatar),
                placeholderImage: UIImage.avatarPlaceholderImage(),
                completed: nil
            )
        }
    }
    
    dynamic private func profileTapped(recognizer: UIGestureRecognizer) {
        selectionClosure?(cell: self)
    }
    
}