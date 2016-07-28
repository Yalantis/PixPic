//
//  NSError+ErrorType.swift
//  PixPic
//
//  Created by Jack Lapin on 17.02.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

extension NSError {
    
    static func authenticationError(type: AuthenticationError) -> NSError {
        switch type {
        case .FacebookError:
            let error = NSError(
                domain: NSBundle.mainBundle().bundleIdentifier!,
                code: 701,
                userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Facebook error", comment: "")]
            )
            
            return error
            
        case .ParseError:
            let error = NSError(
                domain: NSBundle.mainBundle().bundleIdentifier!,
                code: 702,
                userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Parse error", comment: "")]
            )
            
            return error
            
        case .ParseCurrentUserNotExist:
            let error = NSError(
                domain: NSBundle.mainBundle().bundleIdentifier!,
                code: 703,
                userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Parse current user not exist", comment: "")]
            )
            
            return error
            
        case .InvalidAccessToken:
            let error = NSError(
                domain: NSBundle.mainBundle().bundleIdentifier!,
                code: 704,
                userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Access token error", comment: "")]
            )
            
            return error
        
        default:
            return NSError(
                domain: NSBundle.mainBundle().bundleIdentifier!,
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Unsupported type", comment: "")]
            )
        }
    }
    
}
