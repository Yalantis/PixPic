//
//  Activity.swift
//  PixPic
//
//  Created by Jack Lapin on 04.03.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//


enum ActivityType: String {
    case Like = "like"
    case Follow = "follow"
    case Comment = "comment"
}

class Activity: PFObject {
    
    @NSManaged var type: String
    @NSManaged var fromUser: User
    @NSManaged var toUser: User
    @NSManaged var content: PFFile

    private static var onceToken: dispatch_once_t = 0
    
    override class func initialize() {
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }
    
}

extension Activity: PFSubclassing {
    
    static func parseClassName() -> String {
        return "Activity"
    }
    
}