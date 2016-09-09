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

    var didSelectUser: ((cell: PostViewCell) -> Void)?
    var didSelectSettings: ((cell: PostViewCell, items: [AnyObject]) -> Void)?
    private let actionByTapProfile = #selector(didTapProfile)

    private var locator: ServiceLocator!

    @IBOutlet private weak var postImageView: UIImageView!
    @IBOutlet private weak var profileImageView: UIImageView!

    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var profileLabel: UILabel!

    @IBOutlet private weak var settingsButton: UIButton!
    @IBOutlet private weak var indicator: UIActivityIndicatorView!

    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet private weak var likesLebel: UILabel!

    private var likeStatus = LikeStatus.Unknown {
        didSet {
            switch likeStatus {
            case .Liked:
                likeButton.selected = true
                likeButton.enabled = true
            case .NotLiked:
                likeButton.selected = false
                likeButton.enabled = true
            case .Unknown:
                likeButton.enabled = false
            }
        }
    }

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
        likeStatus = .Unknown
        indicator.hidden = false
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

        settingsButton.enabled = false
        if let urlString = post.image.url, url = NSURL(string: urlString) {
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
                NSURL(string: avatar)!,
                placeholderImage: UIImage.avatarPlaceholderImage
            )
        }
        fillLikesQuantity()
        setLikeStatus()
        toggleLikeColor()
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
        let message = "Created by " + username + " with PixPic app."
        let items = [cachedImage, message]

        didSelectSettings?(cell: self, items: items)
    }

    @IBAction func didTapLikeButton(sender: AnyObject) {
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

    private func toggleLikePost() {
        guard let post = post else {
            return
        }
        let activityService: ActivityService = locator.getService()

        if likeStatus == .Liked {
            // Unlike
            likeStatus = .Unknown
            activityService.unlikePostEventually(post) { [weak self] success, error in
                guard let this = self else {
                    return
                }
                if success {
                    this.likeStatus = .NotLiked
                    this.fillLikesQuantity()
                } else {
                    this.likeStatus = .Liked
                }
            }
        } else {
            // Like
            likeStatus = .Unknown
            let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
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
                    this.likeStatus = .Liked
                } else {
                    this.likeStatus = .NotLiked
                }
                indicator.removeFromSuperview()
                this.fillLikesQuantity()
            }
        }
    }

    private func fillLikesQuantity() {
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

    private func setLikeStatus() {
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

    private func getLikesString(count: Int) -> String {
        toggleLikeColor()
        if count == 1 {
            return "\(count) like"
        } else if count == 0 {
            return ""
        } else {
            return "\(count) likes"
        }
    }

    private func toggleLikeColor() {
        let activityService: ActivityService = locator.getService()
        activityService.fetchLikeStatus(post!) { [weak self] likeStatus in
            switch likeStatus {
            case .Liked:
                self?.likeButton.imageView?.tintColor = UIColor.appPinkColor()

            case  .NotLiked, .Unknown:
                self?.likeButton.imageView?.tintColor = UIColor.appWhiteColor()
            }
        }
    }

}
