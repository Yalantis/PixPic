//
//  FeedToolBar.swift
//  P-effect
//
//  Created by Jack Lapin on 05.02.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class FeedToolBar: UIView {
    
    var selectionClosure: (() -> Void)?

    @IBOutlet weak var bottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var topSpaceConstraint: NSLayoutConstraint!
    @IBAction func makePhotoButtonTapped(sender: AnyObject) {
        selectionClosure?()
    }
    
}
