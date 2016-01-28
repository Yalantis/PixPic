//
//  PFInstallation+User.swift
//  P-effect
//
//  Created by Jack Lapin on 28.01.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

extension PFInstallation {
    
    class func addPFUserToCurrentInstallation() {
        let installation = PFInstallation.currentInstallation()
        installation["user"] = PFUser.currentUser()
        installation.saveInBackground()
    }

}
