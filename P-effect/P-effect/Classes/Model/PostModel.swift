//
//  PEFPostModel.swift
//  P-effect
//
//  Created by Jack Lapin on 17.01.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

class PostModel: NSObject {
    
    var post: Post
    
    init(aPost: Post) {
        post = aPost
        super.init()
    }
    
    init(image: PFFile, user: User, comment: String?) {
        post = Post()
        super.init()
        post.image = image
        post.user = user
        if let comment = comment {
            post.comment = comment
        }
    }
}