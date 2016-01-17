//
//  PEFPost.swift
//  P-effect
//
//  Created by Jack Lapin on 15.01.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

var pagination: Int = 0
let displayLimit = 20

class PEFPost: PFObject {
    
    @NSManaged var image: PFFile
    @NSManaged var user: User?
    @NSManaged var comment: String?
    
    override class func initialize() {
        var onceToken: dispatch_once_t = 0
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
    override class func query() -> PFQuery? {
        let query = PFQuery(className: PEFPost.parseClassName())
        query.includeKey("user")
        query.orderByDescending("updatedAt")
        query.limit = displayLimit
        query.skip = pagination * query.limit
        return query
    }
    
}

extension PEFPost: PFSubclassing {
    
    class func parseClassName() -> String {
        return "PEFPost"
    }
    
}
