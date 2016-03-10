//
//  ButtonView.swift
//  P-effect
//
//  Created by AndrewPetrov on 3/10/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class ButtonView: UIView {
    
    private var action: (() -> Void)!
    
    @IBOutlet private weak var button: UIButton!
    
    @IBAction private func buttonAction() {
        action()
    }
    
    static func instanceFromNib(text: String, action: (() -> Void)) -> ButtonView {
        let view = UINib(nibName: String(self), bundle: nil).instantiateWithOwner(nil, options: nil).first as! ButtonView
        view.button.setTitle(text, forState: .Normal)
        view.action = action
        
        return view
    }
    
}
