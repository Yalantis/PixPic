//
//  PostViewCell.swift
//  P-effect
//
//  Created by anna on 1/18/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import Kingfisher
import MHPrettyDate

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
    
    @IBOutlet private weak var settingsButton: UIButton!
    
    var selectionClosure: ((cell: PostViewCell) -> Void)?
    var didSelectSettings: ((cell: PostViewCell) -> Void)?

    let imageLoader = ImageLoaderService()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: "didTapProfile:")
        profileImageView.addGestureRecognizer(imageGestureRecognizer)
        
        let labelGestureRecognizer = UITapGestureRecognizer(target: self, action: "didTapProfile:")
        profileLabel.addGestureRecognizer(labelGestureRecognizer)
        selectionStyle = .None
    }
    
    func configure(withPost post: Post?) {
        guard let post = post else {
            postImageView.image = UIImage.placeholderImage()
            profileImageView.image = UIImage.avatarPlaceholderImage()
            return
        }
        profileLabel.text = post.user?.username
        dateLabel.text = MHPrettyDate.prettyDateFromDate(
            post.createdAt,
            withFormat: MHPrettyDateShortRelativeTime
        )
        profileImageView.layer.cornerRadius = (profileImageView.frame.size.width) / 2
        
        settingsButton.enabled = false
        let indicator = UIActivityIndicatorView().addActivityIndicatorOn(view: postImageView)
        postImageView.kf_setImageWithURL(
            NSURL(string: post.image.url!)!,
            placeholderImage: UIImage.placeholderImage(),
            optionsInfo: nil) { [weak self] _, _, _, _ in
                indicator.removeFromSuperview()
                self?.settingsButton.enabled = true
        }

        guard let user = post.user else {
            profileImageView.image = UIImage.avatarPlaceholderImage()
            return
        }
        if let avatar = user.avatar?.url {
            profileImageView.kf_setImageWithURL(
                NSURL(string: avatar)!,
                placeholderImage: UIImage.avatarPlaceholderImage()
            )
        }
    }
    
    dynamic private func didTapProfile(recognizer: UIGestureRecognizer) {
        selectionClosure?(cell: self)
    }
    
    @IBAction private func didTapSettingsButton() {
        didSelectSettings?(cell: self)
    }
    
}