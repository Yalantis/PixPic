//
//  FollowerViewCell.swift
//  P-effect
//
//  Created by anna on 3/3/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class FollowerViewCell: UITableViewCell, CellInterface {
    
    static let identifier = "FollowerViewCellIdentifier"
    
    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var profileLabel: UILabel!
    
    func configure(withFollower follower: User) {
        if let username = follower.username {
            profileLabel.text = username
        }
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        if let avatar = follower.avatar?.url, let url = NSURL(string: avatar) {
            profileImageView.kf_setImageWithURL(
                url,
                placeholderImage: UIImage.avatarPlaceholderImage()
            )
        } else {
            profileImageView.image = UIImage.avatarPlaceholderImage()
        }
    }

}
