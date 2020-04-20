//
//  TextView.swift
//  PixPic
//
//  Created by AndrewPetrov on 3/10/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class TextView: UIView {

    fileprivate var action: (() -> Void)!

    @IBOutlet fileprivate weak var button: UIButton!

    @IBAction fileprivate func buttonAction() {
        action()
    }

    static func instanceFromNib(_ text: String, action: (() -> Void)) -> TextView {
        let view = UINib(nibName: String(self), bundle: nil).instantiateWithOwner(nil, options: nil).first as! TextView
        view.button.setTitle(text, forState: .Normal)
        view.action = action

        return view
    }

}
