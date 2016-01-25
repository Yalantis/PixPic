//
//  Constants.swift
//  InstaFeedObserver
//
//  Created by Jack Lapin on 13.11.15.
//  Copyright © 2015 Jack Lapin. All rights reserved.
//


struct Constants {
    
    struct ParseApplicationId {
        static let AppID = "8yjIQdP3FPBBe9VwRcsfJrth2dWSDBjsFPC47v2c"
        static let ClientKey = "fJwIVMqkD8DlpYNzfyrESiKQTfqzVU6IrAJnTef3"
    }
    
    struct NotificationKey {
        static let NewPostUploaded = "NewPostUploaded"
    }
    
    struct StoryBoardID {

    }
    
    struct Path {
        static let Documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        static let Tmp = NSTemporaryDirectory()
    }
    
    struct UserDefaultsKeys {

    }
    
    struct UserKey {
        static let Avatar = "avatar"
    }
    
    
    struct Profile {
        static let HeaderHeight = 224 as CGFloat
        static let AvatarImageCornerRadius = 62.5 as CGFloat
        static let AvatarImagePlaceholderName = "profile_placeholder.png" as String
        static let PossibleInsets = 45 as CGFloat
    }
    
    struct DataSource {
        static let QueryLimit = 2 as Int
    }
    
    struct BackButtonTitle {
        static let HideTitlePosition = UIOffsetMake(0, -70)
    }
    
    struct Validation {
        static let WrongLenght = "Lenght of the username have to be more then 3 and less then 30 characters long" as String
        static let AlreadyExist = "Username already exist" as String
        static let SpaceInBegining = "Username can't start with spaces" as String
        static let CharacterSet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789абвгдеёжзийклмнопрстуфхцчшщъыьэюяАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ " as String
        static let SpaceInEnd = "Username can't end with spaces" as String
        static let NumbersAndSymbolsInUsername = "Username have to consist only with letters an numbers" as String
        static let TwoSpacesInRow = "Username can't consist two or more spaces in row" as String
    }
}