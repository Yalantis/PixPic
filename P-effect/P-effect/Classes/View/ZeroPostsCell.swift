//
//  ZeroPostsCell.swift
//  P-effect
//
//  Created by Illya on 1/18/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class ZeroPostsCell: UITableViewCell {
    @IBOutlet weak var noPostsLabel: UILabel!

    func setupText() {
        self.noPostsLabel.text = " No posts available"
    }
    
}
