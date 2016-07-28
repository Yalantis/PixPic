//
//  PFInstallation+User.swift
//  PixPic
//
//  Created by Jack Lapin on 28.01.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

extension PFInstallation {
    
    static func addPFUserToCurrentInstallation() {
        let installation = PFInstallation.currentInstallation()
        installation["user"] = PFUser.currentUser()
        installation.saveInBackground()
    }

}
