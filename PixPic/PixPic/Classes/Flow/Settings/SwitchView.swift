//
//  SwitchView.swift
//  PixPic
//
//  Created by AndrewPetrov on 3/10/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class SwitchView: UIView {
    
    private var action: (Bool -> Void)!
    
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var switchControl: UISwitch!
    
    @IBAction func switchAction(sender: UISwitch) {
        action(sender.on)
    }
    
    static func instanceFromNib(text: String, initialState: Bool = true, action: (Bool -> Void)) -> SwitchView {
        let view = UINib(nibName: String(self), bundle: nil).instantiateWithOwner(nil, options: nil).first as! SwitchView
        view.textLabel.text = text
        view.action = action
        view.switchControl.setOn(initialState, animated: false)
        
        return view
    }
    
}
