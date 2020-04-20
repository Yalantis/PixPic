//
//  PostViewCell.swift
//  PixPic
//
//  Created by anna on 1/18/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import Kingfisher

private let headerViewHeight: CGFloat = 62
private let footerViewHeight: CGFloat = 44

private let suggestLoginMessage = NSLocalizedString("can't_like_no_registration", comment: "")

class PostViewCell: UITableViewCell, CellInterface {

    static let designedHeight = headerViewHeight + footerViewHeight

    weak var post = Post?()

    var didSelectUser: ((_ cell: PostViewCell) -> Void)?
    var didSelectSettings: ((_ cell: PostViewCell, _ items: [AnyObject]) -> Void)?
    fileprivate let actionByTapProfile = #selector(didTapProfile)

    fileprivate var locator: ServiceLocator!

    @IBOutlet fileprivate weak var postImageView: UIImageView!
    @IBOutlet fileprivate weak var profileImageView: UIImageView!

    @IBOutlet fileprivate weak var dateLabel: UILabel!
    @IBOutlet fileprivate weak var profileLabel: UILabel!

    @IBOutlet fileprivate weak var settingsButton: UIButton!
    @IBOutlet fileprivate weak var indicator: UIActivityIndicatorView!

    @IBOutlet fileprivate weak var likeButton: UIButton!
    @IBOutlet fileprivate weak var likesLebel: UILabel!

    fileprivate var likeStatus = LikeStatus.unknown {
        didSet {
            switch likeStatus {
            case .liked:
                likeButton.isSelected = true
                likeButton.isEnabled = true
            case .notLiked:
                likeButton.isSelected = false
                likeButton.isEnabled = true
            case .unknown:
                likeButton.isEnabled = false
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: actionByTapProfile)
        profileImageView.addGestureRecognizer(imageGestureRecognizer)

        let labelGestureRecognizer = UITapGestureRecognizer(target: self, action: actionByTapProfile)
        profileLabel.addGestureRecognizer(labelGestureRecognizer)
        selectionStyle = .none
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        postImageView.image = UIImage.placeholderImage
        profileImageView.image = UIImage.avatarPlaceholderImage
        likeStatus = .unknown
        indicator.isHidden = false
        indicator.startAnimating()
    }

    func configure(with post: Post?, locator: ServiceLocator) {
        guard let post = post else {
            return
        }
        self.locator = locator
        self.post = post
        profileLabel.text = post.user?.username
        dateLabel.text = post.createdAt?.timeAgoSinceNow()
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2

        settingsButton.isEnabled = false
        if let urlString = post.image.url, let url = URL(string: urlString) {
            postImageView.kf_setImageWithURL(
                url,
                placeholderImage: UIImage.placeholderImage,
                optionsInfo: nil) { [weak self] _, _, _, _ in
                    self?.indicator.stopAnimating()
                    self?.settingsButton.enabled = true
            }
        }

        guard let user = post.user else {
            profileImageView.image = UIImage.avatarPlaceholderImage

            return
        }
        if let avatar = user.avatar?.url {
            profileImageView.kf_setImageWithURL(
                URL(string: avatar)!,
                placeholderImage: UIImage.avatarPlaceholderImage
            )
        }
        fillLikesQuantity()
        setLikeStatus()
        toggleLikeColor()
    }

    @objc fileprivate func didTapProfile(_ recognizer: UIGestureRecognizer) {
        didSelectUser?(self)
    }

    @IBAction fileprivate func didTapSettingsButton() {
        let cache = KingfisherManager.sharedManager.cache
        guard let username = profileLabel.text,
            let url = post?.image.url,
            let cachedImage = cache.retrieveImageInDiskCacheForKey(url) else {
                return
        }
        let message = "Created by " + username + " with PixPic app."
        let items = [cachedImage, message]

        didSelectSettings?(cell: self, items: items)
    }

    @IBAction func didTapLikeButton(_ sender: AnyObject) {
        guard ReachabilityHelper.isReachable() else {
            ExceptionHandler.handle(Exception.NoConnection)

            return
        }
        if User.notAuthorized {
            AlertManager.sharedInstance.showLoginAlert(.Like)
        } else {
            toggleLikePost()
        }
    }

    fileprivate func toggleLikePost() {
        guard let post = post else {
            return
        }
        let activityService: ActivityService = locator.getService()

        if likeStatus == .liked {
            // Unlike
            likeStatus = .unknown
            activityService.unlikePostEventually(post) { [weak self] success, error in
                guard let this = self else {
                    return
                }
                if success {
                    this.likeStatus = .notLiked
                    this.fillLikesQuantity()
                } else {
                    this.likeStatus = .liked
                }
            }
        } else {
            // Like
            likeStatus = .unknown
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
            indicator.center = likeButton.center
            indicator.hidesWhenStopped = true
            indicator.startAnimating()
            likeButton.addSubview(indicator)
            activityService.likePostEventually(post) { [weak self] succeeded, error in
                guard let this = self else {
                    return
                }
                if error == nil {
                    log.debug("Attempt to like was \(succeeded) ")
                    this.likeStatus = .liked
                } else {
                    this.likeStatus = .notLiked
                }
                indicator.removeFromSuperview()
                this.fillLikesQuantity()
            }
        }
    }

    fileprivate func fillLikesQuantity() {
        guard let post = post else {
            return
        }
        let attributes = AttributesCache.sharedCache.attributes(for: post)
        if let likesQuantity = attributes?[Constants.Attributes.likesCount] as? Int {
            likesLebel.text = getLikesString(likesQuantity)
        } else {
            let activityService: ActivityService = locator.getService()
            activityService.fetchLikesQuantity(post) { likersCount in
                self.likesLebel.text = self.getLikesString(likersCount)
            }
        }
    }

    fileprivate func setLikeStatus() {
        guard let post = post else {
            return
        }
        let attributes = AttributesCache.sharedCache.attributes(for: post)
        if let status = attributes?[Constants.Attributes.likeStatusByCurrentUser] as! Int? {
            if let likeStatus = LikeStatus(rawValue: status) {
                self.likeStatus = likeStatus
            }
        } else {
            let activityService: ActivityService = locator.getService()
            activityService.fetchLikeStatus(post) { status in
                self.likeStatus = status
            }
        }
    }

    fileprivate func getLikesString(_ count: Int) -> String {
        toggleLikeColor()
        if count == 1 {
            return "\(count) like"
        } else if count == 0 {
            return ""
        } else {
            return "\(count) likes"
        }
    }

    fileprivate func toggleLikeColor() {
        let activityService: ActivityService = locator.getService()
        activityService.fetchLikeStatus(post!) { [weak self] likeStatus in
            switch likeStatus {
            case .liked:
                self?.likeButton.imageView?.tintColor = UIColor.appPinkColor()

            case  .notLiked, .unknown:
                self?.likeButton.imageView?.tintColor = UIColor.appWhiteColor()
            }
        }
    }

}
