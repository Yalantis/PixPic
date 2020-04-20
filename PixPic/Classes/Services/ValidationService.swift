//
//  ValidationService.swift
//  PixPic
//
//  Created by Illya on 1/22/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class ValidationService {

    static func validateUserName(_ userName: String, completion: @escaping (Bool) -> Void) {
        if !isUserNameContainsOnlyLetters(userName) {
            completion(false)

            return
        }
        if userName.characters.count < Constants.ValidationErrors.minUserName ||
            userName.characters.count > Constants.ValidationErrors.maxUserName {
                AlertManager.sharedInstance.showSimpleAlert(Constants.ValidationErrors.wrongLenght)
                completion(false)

                return
        }

        let query = User.query()?.whereKey("username", equalTo: userName)
        query?.getFirstObjectInBackgroundWithBlock { object, error in
            if object != nil {
                AlertManager.sharedInstance.showSimpleAlert(Constants.ValidationErrors.alreadyExist)
                completion(false)
            } else {
                completion(true)
            }
        }
    }

    fileprivate static func isUserNameContainsOnlyLetters(_ userName: String) -> Bool {
        if userName.characters.first == Constants.ValidationErrors.whiteSpace {
            AlertManager.sharedInstance.showSimpleAlert(Constants.ValidationErrors.spaceInBegining)

            return false
        }
        let invalidCharacterSet = CharacterSet(charactersIn: Constants.ValidationErrors.characterSet).inverted
        if userName.rangeOfCharacter(from: invalidCharacterSet) != nil {
            AlertManager.sharedInstance.showSimpleAlert(Constants.ValidationErrors.numbersAndSymbolsInUsername)

            return false
        } else {
            var previousChar = Constants.ValidationErrors.whiteSpace as Character
            for char in userName.characters {
                if previousChar == Constants.ValidationErrors.whiteSpace && char == Constants.ValidationErrors.whiteSpace {
                    AlertManager.sharedInstance.showSimpleAlert(Constants.ValidationErrors.twoConsecutiveSpaces)

                    return false
                }
                previousChar = char
            }
            if userName.characters.last == Constants.ValidationErrors.whiteSpace {
                AlertManager.sharedInstance.showSimpleAlert(Constants.ValidationErrors.spaceInEnd)

                return false
            }
        }

        return true
    }

}
