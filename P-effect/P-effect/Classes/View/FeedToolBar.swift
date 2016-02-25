//
//  FeedToolBar.swift
//  P-effect
//
//  Created by Jack Lapin on 05.02.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class FeedToolBar: UIView {
    
    var didSelectPhoto: (() -> Void)?

    @IBOutlet private weak var bottomSpaceConstraint: NSLayoutConstraint!
    @IBOutlet private weak var topSpaceConstraint: NSLayoutConstraint!
    
    static func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil) -> FeedToolBar? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiateWithOwner(nil, options: nil)[0] as? FeedToolBar
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        bottomSpaceConstraint.constant = -Constants.BaseDimensions.ToolBarHeight
        topSpaceConstraint.constant = Constants.BaseDimensions.ToolBarHeight
    }
    
    func animateButton(isLifting isLifting: Bool) {
        bottomSpaceConstraint.constant = isLifting ? 0 : -Constants.BaseDimensions.ToolBarHeight
        topSpaceConstraint.constant = isLifting ? 0 : Constants.BaseDimensions.ToolBarHeight
        UIView.animateWithDuration(
            0.7,
            delay: 0,
            usingSpringWithDamping: 0.4,
            initialSpringVelocity: 0.7,
            options: .CurveEaseInOut,
            animations: {
                self.layoutIfNeeded()
            },
            completion: nil
        )
    }
    
    @IBAction func makePhotoButtonTapped() {
        didSelectPhoto?()
    }
    
}
