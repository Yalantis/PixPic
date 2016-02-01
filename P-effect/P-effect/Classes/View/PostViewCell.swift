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
    
    private var isImageDowloaded = false
    private var isAvatarDowloaded = false
    
    @IBOutlet private weak var postImageView: UIImageView!
    @IBOutlet private weak var profileImageView: UIImageView!
    
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var profileLabel: UILabel!
    
    let imageLoader = ImageLoaderService()
    weak var delegate: PostViewCellDelegate?
    
    var post: Post? {
        didSet {
            setContent()
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
        dateLabel.text = MHPrettyDate.prettyDateFromDate(post?.createdAt, withFormat: MHPrettyDateShortRelativeTime)
        if !isImageDowloaded {
            postImageView.image = UIImage(named: "image_placeholder")
        }
        let convertPFFileToImageActivityIndicator = UIActivityIndicatorView()
        postImageView.addSubview(convertPFFileToImageActivityIndicator)
        convertPFFileToImageActivityIndicator.startAnimating()
        imageLoader.getImageForContentItem(post?.image) { [weak self] image, error in
            if let error = error {
                print("\(error)")
            } else {
                self?.postImageView.image = image
                convertPFFileToImageActivityIndicator.stopAnimating()
                self?.isImageDowloaded = true
            }
        }
        if !isAvatarDowloaded {
            profileImageView.image = UIImage(named: "user_male_50")
        }

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
                    self?.isAvatarDowloaded = true
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
    
    dynamic private func profileTapped(recognizer: UIGestureRecognizer) {
       delegate?.didChooseCellWithUser((post?.user)!)
    }
    
}