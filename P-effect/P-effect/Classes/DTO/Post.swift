//
//  Post.swift
//  P-effect
//
//  Created by Jack Lapin on 15.01.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

class Post: PFObject {
    
    @NSManaged var image: PFFile
    @NSManaged var user: User?
    @NSManaged var comment: String?
    
    override class func initialize() {
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    class func sortedQuery() -> PFQuery {
        let query = PFQuery(className: Post.parseClassName())
        query.includeKey("user")
        query.orderByDescending("updatedAt")
        return query
    }
    
}

extension Post: PFSubclassing {
    
    class func parseClassName() -> String {
        return "Post"
    }
    
}
