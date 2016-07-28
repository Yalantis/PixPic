//
//  FeedToolBar.swift
//  PixPic
//
//  Created by Jack Lapin on 05.02.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
private let buttonAnimationDuration: NSTimeInterval = 0.7

class FeedToolBar: UIView {
    
    var didSelectPhoto: (() -> Void)?

    @IBOutlet private weak var bottomSpaceConstraint: NSLayoutConstraint!
    
    static func loadFromNibNamed(nibNamed: String, bundle: NSBundle? = nil) -> FeedToolBar? {
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
    }
    
    func animateButton(isLifting isLifting: Bool) {
        bottomSpaceConstraint.constant = isLifting ? 0 : -Constants.BaseDimensions.ToolBarHeight
        UIView.animateWithDuration(
            buttonAnimationDuration,
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
