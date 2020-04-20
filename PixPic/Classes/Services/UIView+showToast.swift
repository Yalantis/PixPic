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

    func showToastActivityWithDuration(_ duration: TimeInterval) {
        makeToastActivity(CSToastPositionCenter)

        let delayTime = DispatchTime.now() + Double(Int64(duration * TimeInterval(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime) {
            self.hideToastActivity()
        }
    }

}
