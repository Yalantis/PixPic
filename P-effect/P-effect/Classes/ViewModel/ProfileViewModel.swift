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
    
    func userAvatar(completion: LoadingImageCompletion) {
        ImageLoaderService().getImageForContentItem(user.avatar) { (image, error) -> () in
            completion(image: image, error: error)
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
