//
//  ValidationService.swift
//  PixPic
//
//  Created by Illya on 1/22/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class ValidationService {
    
    static func validateUserName(userName: String, completion: Bool -> Void) {
        if !isUserNameContainsOnlyLetters(userName) {
            completion(false)
            
            return
        }
        if userName.characters.count < Constants.ValidationErrors.MinUserName ||
            userName.characters.count > Constants.ValidationErrors.MaxUserName {
                AlertManager.sharedInstance.showSimpleAlert(Constants.ValidationErrors.WrongLenght)
                completion(false)
                
                return
        }
        
        let query = User.query()?.whereKey("username", equalTo: userName)
        query?.getFirstObjectInBackgroundWithBlock { object, error in
            if object != nil {
                AlertManager.sharedInstance.showSimpleAlert(Constants.ValidationErrors.AlreadyExist)
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    private static func isUserNameContainsOnlyLetters(userName: String) -> Bool {
        if userName.characters.first == Constants.ValidationErrors.WhiteSpace {
            AlertManager.sharedInstance.showSimpleAlert(Constants.ValidationErrors.SpaceInBegining)
            
            return false
        }
        let invalidCharacterSet = NSCharacterSet(charactersInString: Constants.ValidationErrors.CharacterSet).invertedSet
        if userName.rangeOfCharacterFromSet(invalidCharacterSet) != nil {
            AlertManager.sharedInstance.showSimpleAlert(Constants.ValidationErrors.NumbersAndSymbolsInUsername)
            
            return false
        } else {
            var previousChar = Constants.ValidationErrors.WhiteSpace as Character
            for char in userName.characters {
                if previousChar == Constants.ValidationErrors.WhiteSpace && char == Constants.ValidationErrors.WhiteSpace {
                    AlertManager.sharedInstance.showSimpleAlert(Constants.ValidationErrors.TwoConsecutiveSpaces)
                    
                    return false
                }
                previousChar = char
            }
            if userName.characters.last == Constants.ValidationErrors.WhiteSpace {
                AlertManager.sharedInstance.showSimpleAlert(Constants.ValidationErrors.SpaceInEnd)
                
                return false
            }
        }
        
        return true
    }
    
}
