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

private let headerViewHeight: CGFloat = 78
private let footerViewHeight: CGFloat = 48

class PostViewCell: UITableViewCell {
    
    static let identifier = "PostViewCellIdentifier"
    static let designedHeight = headerViewHeight + footerViewHeight
    
    static var nib: UINib? {
        let nib = UINib(nibName: String(self), bundle: nil)
        return nib
    }
    var didSelectUser: ((cell: PostViewCell) -> Void)?
    var didSelectSettings: ((cell: PostViewCell) -> Void)?

    @IBOutlet private weak var postImageView: UIImageView!
    @IBOutlet private weak var profileImageView: UIImageView!
    
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var profileLabel: UILabel!
    
    @IBOutlet private weak var settingsButton: UIButton!
    
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
        if let urlString = post.image.url {
            let indicator = UIActivityIndicatorView().addActivityIndicatorOn(view: postImageView)

            let url = NSURL(string: urlString)
            postImageView.kf_setImageWithURL(
                url!,
                placeholderImage: UIImage.placeholderImage(),
                optionsInfo: nil) { [weak self] _, _, _, _ in
                    indicator.removeFromSuperview()
                    self?.settingsButton.enabled = true
            }
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
        didSelectUser?(cell: self)
    }
    
    @IBAction private func didTapSettingsButton() {
        didSelectSettings?(cell: self)
    }
    
}