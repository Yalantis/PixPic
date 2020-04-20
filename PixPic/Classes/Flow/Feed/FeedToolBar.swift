//
//  FeedToolBar.swift
//  PixPic
//
//  Created by Jack Lapin on 05.02.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
private let buttonAnimationDuration: TimeInterval = 0.7

class FeedToolBar: UIView {

    var didSelectPhoto: (() -> Void)?

    @IBOutlet fileprivate weak var bottomSpaceConstraint: NSLayoutConstraint!

    static func loadFromNibNamed(_ nibNamed: String, bundle: Bundle? = nil) -> FeedToolBar? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiate(withOwner: nil, options: nil)[0] as? FeedToolBar
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        bottomSpaceConstraint.constant = -Constants.BaseDimensions.toolBarHeight
    }

    func animateButton(isLifting: Bool) {
        bottomSpaceConstraint.constant = isLifting ? 0 : -Constants.BaseDimensions.toolBarHeight
        UIView.animate(
            withDuration: buttonAnimationDuration,
            delay: 0,
            usingSpringWithDamping: 0.4,
            initialSpringVelocity: 0.7,
            options: UIViewAnimationOptions(),
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
