//
//  PostViewCell.swift
//  Pix Pic
//
//  Created by anna on 1/18/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import Kingfisher
import MHPrettyDate

private let headerViewHeight: CGFloat = 87
private let footerViewHeight: CGFloat = 40

private let actionByTapProfile = #selector(PostViewCell.didTapProfile)

class PostViewCell: UITableViewCell, CellInterface {
    
    static let designedHeight = headerViewHeight + footerViewHeight
    
    weak var post = Post?()
    
    var didSelectUser: ((cell: PostViewCell) -> Void)?
    var didSelectSettings: ((cell: PostViewCell, items: [AnyObject]) -> Void)?

    @IBOutlet private weak var postImageView: UIImageView!
    @IBOutlet private weak var profileImageView: UIImageView!
    
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var profileLabel: UILabel!
    
    @IBOutlet private weak var settingsButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: actionByTapProfile)
        profileImageView.addGestureRecognizer(imageGestureRecognizer)
        
        let labelGestureRecognizer = UITapGestureRecognizer(target: self, action: actionByTapProfile)
        profileLabel.addGestureRecognizer(labelGestureRecognizer)
        selectionStyle = .None
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        postImageView.image = UIImage.placeholderImage
        profileImageView.image = UIImage.avatarPlaceholderImage
    }
    
    func configure(withPost post: Post?) {
        guard let post = post else {
            return
        }
        self.post = post
        profileLabel.text = post.user?.username
        dateLabel.text = MHPrettyDate.prettyDateFromDate(
            post.createdAt,
            withFormat: MHPrettyDateFormatNoTime
        )
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        
        settingsButton.enabled = false
        if let urlString = post.image.url, url = NSURL(string: urlString) {
            let indicator = UIActivityIndicatorView().addActivityIndicatorOn(view: postImageView)
            postImageView.kf_setImageWithURL(
                url,
                placeholderImage: UIImage.placeholderImage,
                optionsInfo: nil) { [weak self] _, _, _, _ in
                    indicator.removeFromSuperview()
                    self?.settingsButton.enabled = true
            }
        }

        guard let user = post.user else {
            profileImageView.image = UIImage.avatarPlaceholderImage
            
            return
        }
        if let avatar = user.avatar?.url {
            profileImageView.kf_setImageWithURL(
                NSURL(string: avatar)!,
                placeholderImage: UIImage.avatarPlaceholderImage
            )
        }
    }
    
    @objc private func didTapProfile(recognizer: UIGestureRecognizer) {
        didSelectUser?(cell: self)
    }
    
    @IBAction private func didTapSettingsButton() {
        let cache = KingfisherManager.sharedManager.cache
        guard let username = profileLabel.text,
            url = post?.image.url,
            cachedImage = cache.retrieveImageInDiskCacheForKey(url) else {
                return
        }
        let message = "Created by " + username + " with Pix Pic app."
        let items = [cachedImage, message]
        
        didSelectSettings?(cell: self, items: items)
    }

}