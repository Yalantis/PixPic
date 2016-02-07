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

    class func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil) -> FeedToolBar? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiateWithOwner(nil, options: nil)[0] as? FeedToolBar
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @IBOutlet weak var bottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var topSpaceConstraint: NSLayoutConstraint!
    
    @IBAction func makePhotoButtonTapped() {
        selectionClosure?()
    }
    
}
