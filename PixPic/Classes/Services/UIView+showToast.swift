//
//  ToastActivityHelper.swift
//  PixPic
//
//  Created by Illya on 2/22/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit
import Toast

extension UIView {

    func showToastActivityWithDuration(duration: NSTimeInterval) {
        makeToastActivity(CSToastPositionCenter)
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(duration * NSTimeInterval(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.hideToastActivity()
        }
    }
    
}
