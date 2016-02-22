//
//  ErrorHandler.swift
//  P-effect
//
//  Created by anna on 1/21/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation


func handleError(error: NSError) {
    
    var message: String?
    
    let errorCode = error.code

    if error.domain == FBSDKErrorDomain {
        
        switch errorCode {
        case FBSDKErrorCode.NetworkErrorCode.rawValue:
            message = "A request failed due to a network error"
        case FBSDKErrorCode.UnknownErrorCode.rawValue:
            message = "The error code for unknown errors"
        default:
            message = error.localizedDescription
            break
        }
        
    } else if error.domain == NSURLErrorDomain {
        
        switch (error.domain, error.code) {
        case (NSURLErrorDomain, NSURLErrorCancelled):
            return
        case (NSURLErrorDomain, NSURLErrorCannotFindHost),
        (NSURLErrorDomain, NSURLErrorDNSLookupFailed),
        (NSURLErrorDomain, NSURLErrorCannotConnectToHost),
        (NSURLErrorDomain, NSURLErrorNetworkConnectionLost),
        (NSURLErrorDomain, NSURLErrorNotConnectedToInternet):
            message = "The Internet connection appears to be offline"
        default:
            message = error.localizedDescription
        }

    } else if error.domain == PFParseErrorDomain {
        
        switch errorCode {
        case PFErrorCode.ErrorConnectionFailed.rawValue:
            message = "Connection Failed"
        case PFErrorCode.ErrorFacebookIdMissing.rawValue:
            message = "Facebook id missing from request"
        case PFErrorCode.ErrorObjectNotFound.rawValue:
            message = "Object Not Found"
        case PFErrorCode.ErrorFacebookInvalidSession.rawValue:
            message = "Invalid Facebook session"
        default:
            message = error.localizedDescription
            break
        }
        
    }
    AlertService.sharedInstance.delegate?.showSimpleAlert(message)
}