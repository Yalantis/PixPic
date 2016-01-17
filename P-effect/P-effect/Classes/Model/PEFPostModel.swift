//
//  PEFPostModel.swift
//  P-effect
//
//  Created by Jack Lapin on 17.01.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

class PEFPostModel: NSObject {
    
    var post: PEFPost
    
    init(aPost: PEFPost) {
        post = aPost
        super.init()
    }
    
    init(image: PFFile, user: User, comment: String?) {
        post = PEFPost()
        super.init()
        post.image = image
        post.user = user
        if let comment = comment {
            post.comment = comment
        }
    }
}