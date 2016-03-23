//
//  ComplaintService.swift
//  P-effect
//
//  Created by Illya on 3/1/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

private let complaintSuccessfull = "Thank you for complaint"
private let nilUserInPost = "Nil user in post"
private let noObjectsFoundErrorCode = 101

typealias ComplainCompletion = (Bool, NSError?) -> Void

enum ComplaintReason: String {
    case UserAvatar = "User Avatar"
    case PostImage = "Post Image"
    case Username = "Username"
}

enum ComplaintRejectReason: String {
    case SelfComplaint = "You can't make a complaint on yourself"
    case AlreadyComplainedPost = "You already make a complaint on this post"
    case AnonymousComlaint = "You can't make a complaint without registration"
}

class ComplaintService {
    
    private lazy var reachabilityService = ReachabilityService()
    
    func complaintUsername(user: User, post: Post? = nil, completion: ComplainCompletion) {
        if !shouldContinueExecutionWith(user) {
            return
        }
        let complaint = Complaint(user: user, post: post, reason: ComplaintReason.Username)
        sendComplaint(complaint) { result, error in
            completion(result, error)
        }
    }
    
    func complaintUserAvatar(user: User, post: Post? = nil, completion: ComplainCompletion) {
        if !shouldContinueExecutionWith(user) {
            return
        }
        let complaint = Complaint(user: user, post: post, reason: ComplaintReason.UserAvatar)
        sendComplaint(complaint) { result, error in
            completion(result, error)
        }
    }
    
    func complaintPost(post: Post, completion: ComplainCompletion) {
        guard let user = post.user else {
            log.debug(nilUserInPost)
            
            return
        }
        if !shouldContinueExecutionWith(user) {
            return
        }
        let complaint = Complaint(user: user, post: post, reason: ComplaintReason.PostImage)
        performIfComplaintExsist(complaint) { [weak self] existence in
            guard let this = self else {
                return
            }
            if !existence {
                this.sendComplaint(complaint) { result, error in
                    completion(result, error)
                }
            } else {
                AlertManager.sharedInstance.showSimpleAlert(ComplaintRejectReason.AlreadyComplainedPost.rawValue)
            }
        }
    }
    
    // You should check reachability befor using this method
    func performIfComplaintExsist(complaint: Complaint, existence: Bool -> Void)  {
        complaint.postQuery().getFirstObjectInBackgroundWithBlock { object, error in
            if object != nil {
                existence(true)
                
                return
            }
            guard let error = error where error.code == noObjectsFoundErrorCode else {
                return
            }
            existence(false)
            
            return
        }
    }
    
    //MARK: Private methods
    private func shouldContinueExecutionWith(user:User) -> Bool {
        if user.isCurrentUser {
            AlertManager.sharedInstance.showSimpleAlert(ComplaintRejectReason.SelfComplaint.rawValue)
            
            return false
        }
        
        if User.notAuthorized {
            AlertManager.sharedInstance.showSimpleAlert(ComplaintRejectReason.AnonymousComlaint.rawValue)
            
            return false
        }
        
        return reachabilityService.isReachable()
    }
    
    private func sendComplaint(complaint: Complaint, completion: ComplainCompletion) {
        complaint.saveInBackgroundWithBlock { succeeded, error in
            if succeeded {
                AlertManager.sharedInstance.showSimpleAlert(complaintSuccessfull)
                completion(true, nil)
            } else {
                completion(false, error)
            }
        }
    }
    
}
