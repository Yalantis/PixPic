//
//  ExceptionHandler.swift
//  PixPic
//
//  Created by AndrewPetrov on 2/2/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

enum Exception: String, Error {
    
    case NoConnection = "There is no internet connection"
    case CantApplyStickers = "You can't apply stickers to the photo"
    case CantCreateParseFile = "You can't create parse file"
    case InvalidSessionToken = "You can't get authorization data from Facebook"
    
}

class ExceptionHandler {

    static func handle(_ exception: Exception) {
        AlertManager.sharedInstance.showSimpleAlert(exception.rawValue)
    }

}
