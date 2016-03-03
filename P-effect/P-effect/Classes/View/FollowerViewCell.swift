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
    
    func configure(withUser user: User) {
        profileLabel.text = user.username
        
        profileImageView.layer.cornerRadius = (profileImageView.frame.size.width) / 2
        if let avatar = user.avatar?.url {
            profileImageView.sd_setImageWithURL(
                NSURL(string: avatar),
                placeholderImage: UIImage.avatarPlaceholderImage(),
                completed: nil
            )
        }
    }

}
