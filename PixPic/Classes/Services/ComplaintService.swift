//
//  ComplaintService.swift
//  PixPic
//
//  Created by Illya on 3/1/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

private let complaintSuccessfull = NSLocalizedString("thanks_complaint", comment: "")
private let nilUserInPost = NSLocalizedString("nil_user_in_post", comment: "")
private let noObjectsFoundErrorCode = 101

private let selfComplaint = NSLocalizedString("complaint_yourself", comment: "")
private let alreadyComplainedPost = NSLocalizedString("already_complaint", comment: "")
private let anonymousComlaint = NSLocalizedString("complaint_without_registration", comment: "")

typealias ComplainCompletion = (Bool, NSError?) -> Void

enum ComplaintReason: String {
    case UserAvatar = "user_avatar"
    case PostImage = "post_image"
    case Username = "username"
}

class ComplaintService {
        
    func complainAboutUsername(user: User, completion: ComplainCompletion) {
        guard shouldContinueExecutionWith(user) else {
            return
        }
        let complaint = Complaint(user: user, post: nil, reason: .Username)
        sendComplaint(complaint) { result, error in
            completion(result, error)
        }
    }
    
    func complainAboutUserAvatar(user: User, completion: ComplainCompletion) {
        guard shouldContinueExecutionWith(user) else {
            return
        }
        let complaint = Complaint(user: user, post: nil, reason: .UserAvatar)
        sendComplaint(complaint) { result, error in
            completion(result, error)
        }
    }
    
    func complainAboutPost(post: Post, completion: ComplainCompletion) {
        guard let user = post.user else {
            log.debug(nilUserInPost)
            
            return
        }
        guard shouldContinueExecutionWith(user) else {
            return
        }
        let complaint = Complaint(user: user, post: post, reason: .PostImage)
        performIfComplaintExsist(complaint) { [weak self] existence in
            if !existence {
                self?.sendComplaint(complaint) { result, error in
                    completion(result, error)
                }
            } else {
                AlertManager.sharedInstance.showSimpleAlert(alreadyComplainedPost)
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
            AlertManager.sharedInstance.showSimpleAlert(selfComplaint)
            
            return false
        }
        
        if User.notAuthorized {
            AlertManager.sharedInstance.showSimpleAlert(anonymousComlaint)
            
            return false
        }
        
        return ReachabilityHelper.isReachable()
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
