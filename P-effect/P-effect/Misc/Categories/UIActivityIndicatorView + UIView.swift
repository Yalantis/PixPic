//
//  UIActivityIndicatorView + UIView.swift
//  P-effect
//
//  Created by Jack Lapin on 29.02.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

extension UIActivityIndicatorView {
    
    func addActivityIndicatorOn(view view: UIView) -> UIActivityIndicatorView {
        
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        indicator.center = CGPointMake(view.frame.size.height/2, view.frame.size.width/2)
        indicator.hidesWhenStopped = true
        indicator.startAnimating()
        view.addSubview(indicator)
        
        return indicator
    }
    
}
