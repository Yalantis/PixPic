//
//  Post.swift
//  PixPic
//
//  Created by Jack Lapin on 15.01.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

class Post: PFObject {
    
    @NSManaged var image: PFFile
    @NSManaged var user: User?
    @NSManaged var comment: String?
    
    private static var onceToken: dispatch_once_t = 0
    
    static var sortedQuery: PFQuery {
        let query = PFQuery(className: Post.parseClassName())
        query.includeKey("user")
        query.orderByDescending("updatedAt")
        
        return query
    }
    
    override class func initialize() {
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    convenience init(image: PFFile, user: User, comment: String?) {
        self.init()
        
        self.image = image
        self.user = user
        self.comment = comment
    }
    
}

extension Post: PFSubclassing {
    
    static func parseClassName() -> String {
        return "Post"
    }
    
}
