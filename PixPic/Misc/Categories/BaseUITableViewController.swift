//
//  BaseUITableViewController.swift
//  PixPic
//
//  Created by AndrewPetrov on 6/20/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class BaseUITableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftButton = UIBarButtonItem(
            image: UIImage.appBackButton,
            style: .Plain,
            target: self,
            action: #selector(navigateBack)
        )
        navigationItem.leftBarButtonItem = leftButton
    }
    
    @objc private func navigateBack() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if let subviews = navigationController?.navigationBar.subviews {
            for view in subviews {
                view.exclusiveTouch = true
            }
        }
    }
    
}
