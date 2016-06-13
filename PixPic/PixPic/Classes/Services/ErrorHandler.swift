//
//  ErrorHandler.swift
//  PixPic
//
//  Created by anna on 1/21/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class ErrorHandler {

    static func handle(error: NSError) {
        var message: String
        let errorCode = error.code

        if error.domain == FBSDKErrorDomain {
            switch errorCode {
            case FBSDKErrorCode.NetworkErrorCode.rawValue:
                message = "The request failed due to a network error"
                
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
                message = "Connection is failed"
                
            case PFErrorCode.ErrorFacebookIdMissing.rawValue:
                message = "Facebook id is missed in request"
                
            case PFErrorCode.ErrorObjectNotFound.rawValue:
                message = "Object Not Found"
                
            case PFErrorCode.ErrorFacebookInvalidSession.rawValue:
                message = "Facebook session is invalid"
                
            default:
                message = error.localizedDescription
                break
            }
        } else if error.domain == NSBundle.mainBundle().bundleIdentifier {

            message = error.localizedDescription
        }
        message = error.localizedDescription

        AlertManager.sharedInstance.showSimpleAlert(message)
    }
}