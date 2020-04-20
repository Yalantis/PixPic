//
//  Complaint.swift
//  PixPic
//
//  Created by Illya on 3/1/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class Complaint: PFObject {

    private static var __once: () = {
            self.registerSubclass()
        }()

    @NSManaged var complainer: User
    @NSManaged var complaintReason: String
    @NSManaged var suspectedUser: User
    @NSManaged var suspectedPost: Post?
    fileprivate static var onceToken: Int = 0

    override class func initialize() {
        _ = Complaint.__once
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
        query.cachePolicy = .NetworkElseCache
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
