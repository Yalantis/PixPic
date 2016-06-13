//
//  Complaint.swift
//  PixPic
//
//  Created by Illya on 3/1/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class Complaint: PFObject {
    
    @NSManaged var complainer: User
    @NSManaged var complaintReason: String
    @NSManaged var suspectedUser: User
    @NSManaged var suspectedPost: Post?
    private static var onceToken: dispatch_once_t = 0

    override class func initialize() {
        dispatch_once(&onceToken) {
            self.registerSubclass()
        }
    }

    convenience init(user: User, post: Post? = nil, reason: ComplaintReason) {
        self.init()
        
        if let post = post {
            suspectedPost = post
        }
        guard let complainer = User.currentUser() else {
            log.debug("Nil current user")
            
            return
        }
        self.complainer = complainer
        self.complaintReason = NSLocalizedString(reason.rawValue, comment: "")
        self.suspectedUser = user
    }
    
    func postQuery() -> PFQuery {
        let query = PFQuery(className: Complaint.parseClassName())
        query.orderByDescending("updatedAt")
        query.whereKey("complainer", equalTo: complainer)
        // query is called only when suspectedPost != nil
        query.whereKey("suspectedPost", equalTo: suspectedPost!)
        query.whereKey("suspectedUser", equalTo: suspectedUser)

        return query
    }
    
}

extension Complaint: PFSubclassing {
    
    static func parseClassName() -> String {
        return "Complaint"
    }
    
}