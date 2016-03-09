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
        profileLabel.text = follower.username
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        if let avatar = follower.avatar?.url {
            profileImageView.kf_setImageWithURL(
                NSURL(string: avatar)!,
                placeholderImage: UIImage.avatarPlaceholderImage()
            )
        } else {
            profileImageView.image = UIImage.avatarPlaceholderImage()
        }
    }

}
