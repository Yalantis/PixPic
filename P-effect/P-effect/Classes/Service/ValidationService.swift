//
//  ValidationService.swift
//  P-effect
//
//  Created by Illya on 1/22/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class ValidationService: NSObject {
    class func valdateUserName(userName: String, completion: (Bool)->()) {
        if !userNameContainsOnlyLetters(userName) {
            completion(false)
            return
        }
        
        if userName.characters.count < Constants.Validation.MinUserName && userName.characters.count > Constants.Validation.MaxUserName {
            AlertService.simpleAlert(Constants.Validation.WrongLenght)
            completion (false)
            return
        }
        
        let query = PFUser.query()?.whereKey("username", equalTo: userName)
        query?.getFirstObjectInBackgroundWithBlock() { (object, error) -> Void in
        if object != nil {
            AlertService.simpleAlert(Constants.Validation.AlreadyExist)
            completion(false)
        } else {
            completion(true)
        }
        }
    }
}

    private func userNameContainsOnlyLetters(userName: String) -> Bool {
        if userName.characters.first == ns {
            AlertService.simpleAlert(Constants.Validation.SpaceInBegining)
            return false
        }
        let characterSet: NSCharacterSet = NSCharacterSet(charactersInString: Constants.Validation.CharacterSet)
        if let match = userName.rangeOfCharacterFromSet(characterSet.invertedSet) {
            AlertService.simpleAlert(Constants.Validation.NumbersAndSymbolsInUsername)
            return false
        } else {
            var previousChar = " " as Character
            for char in userName.characters {
                if ((previousChar == " ")  && (char == " ")) {
                    AlertService.simpleAlert(Constants.Validation.TwoSpacesInRow)
                    return false
                }
                previousChar = char
            }
            if userName.characters.last == " " {
                AlertService.simpleAlert(Constants.Validation.SpaceInEnd)
                return false
            }
        }
        
    return true
    }
