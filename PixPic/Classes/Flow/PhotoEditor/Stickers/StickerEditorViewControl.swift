//
//  StickerEditorViewControl.swift
//  PixPic
//
//  Created by AndrewPetrov on 4/14/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class StickerEditorViewControl: UIImageView {

    init(image: UIImage?, gestureRecognizer: UIGestureRecognizer) {
        super.init(image: image)

        self.addGestureRecognizer(gestureRecognizer)
        self.frame = CGRect(x: 0,
                            y: 0,
                            width: Constants.StickerEditor.stickerViewControlSize,
                            height: Constants.StickerEditor.stickerViewControlSize)

        layer.cornerRadius = frame.width / 2
        backgroundColor = UIColor.appWhiteColor()
        userInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
