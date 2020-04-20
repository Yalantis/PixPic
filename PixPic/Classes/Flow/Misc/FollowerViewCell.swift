//
//  FollowerViewCell.swift
//  PixPic
//
//  Created by anna on 3/3/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class FollowerViewCell: UITableViewCell, CellInterface {

    @IBOutlet fileprivate weak var profileImageView: UIImageView!
    @IBOutlet fileprivate weak var profileLabel: UILabel!

    func configure(withFollower follower: User) {
        profileLabel.text = follower.username ?? ""
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        if let avatar = follower.avatar?.url, let url = URL(string: avatar) {
            profileImageView.kf_setImageWithURL(
                url,
                placeholderImage: UIImage.avatarPlaceholderImage
            )
        } else {
            profileImageView.image = UIImage.avatarPlaceholderImage
        }
    }

}
