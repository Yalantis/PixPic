//
//  ProfileModel.swift
//  P-effect
//
//  Created by Illya on 1/20/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class ProfileViewModel: NSObject {
    var user: User
    
    init(profileUser: User) {
        user = profileUser
        super.init()
    }
    
    func userName() -> String{
        return  user.username!
    }
    
    func userAvatar(image:(UIImage) -> (), downloadingError:(NSError?) -> ()) {
        if let avatar = user.avatar {
            avatar.getDataInBackgroundWithBlock {
                (imageData: NSData?, error: NSError?) -> Void in
                if error == nil, let imageData = imageData {
                    image(UIImage(data:imageData)!)
                } else {
                    downloadingError(error)
                }
            }
        }
    }
    
    func userIsCurrentUser() -> Bool {
        if let currentUser = User.currentUser() {
            if ( currentUser.facebookId == user.facebookId ){
                return true
            }
        }
        return false
    }
    
}
