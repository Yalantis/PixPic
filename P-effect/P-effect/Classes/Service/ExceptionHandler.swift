//
//  ExceptionHandler.swift
//  P-effect
//
//  Created by AndrewPetrov on 2/2/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

enum Exception: String, ErrorType {
    
    case NoConnection = "There is no internet connection"
    case CantApplyEffects = "Can't apply effects to photo"
    case CantCreateParseFile = "Can't create parse file"
    
}

class ExceptionHandler {
    
    static func handle(exception: Exception) {
        AlertService.simpleAlert(exception.rawValue)
    }
    
}