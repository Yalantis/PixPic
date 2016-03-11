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
    
    struct NotificationName {
        static let NewPostUploaded = "NewPostUploaded"
    }
    
    struct BaseDimensions {
        static let ToolBarHeight: CGFloat = 50.0
        static let NavBarWithStatusBarHeight: CGFloat = 64.0
    }
    
    struct FileSize {
        static let MaxUploadSizeBytes = 10485760
    }
    
    struct Path {
        static let Documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        static let Tmp = NSTemporaryDirectory()
    }
    
    struct Storyboard {
        static let Authorization = "Authorization"
        static let Feed = "Feed"
        static let PhotoEditor = "PhotoEditor"
        static let Profile = "Profile"
        static let Settings = "Settings"
        static let LaunchScreen = "LaunchScreen"
    }
    
    struct UserDefaultsKeys {
        static let RemoteNotifications = "RemoteNotifications"
    }
    
    struct UserKey {
        static let Avatar = "avatar"
    }
    
    
    struct Profile {
        static let ToastActivityDuration = 5.0
        static let HeaderHeight: CGFloat = 322
        static let AvatarImageCornerRadius: CGFloat = 95.5
        static let AvatarImagePlaceholderName = "profile_placeholder.png"
        static let PossibleInsets: CGFloat = 45
        static let SettingsButtonImage = "edit_icon"
        static let NavigationTitle = "Profile"
    }
    
    struct DataSource {
        static let QueryLimit = 10 as Int
    }
    
    struct BackButtonTitle {
        static let HideTitlePosition = UIOffsetMake(0, -70)
    }
    
    struct ValidationErrors {
        static let WrongLenght = "Lenght of the username have to be more then 3 and less then 30 characters long" as String
        static let AlreadyExist = "Username already exist" as String
        static let SpaceInBegining = "Username can't start with spaces" as String
        static let CharacterSet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789абвгдеёжзийклмнопрстуфхцчшщъыьэюяАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ " as String
        static let SpaceInEnd = "Username can't end with spaces" as String
        static let NumbersAndSymbolsInUsername = "Username have to consist only with letters an numbers" as String
        static let TwoSpacesInRow = "Username can't consist two or more spaces in row" as String
        static let MinUserName: Int = 3
        static let MaxUserName: Int = 30
        static let WhiteSpace: Character = " "
    }
    
    struct PhotoEditor {
        static let ImageViewControllerSegue = "ImageViewControllerSegue"
        static let EffectsPickerSegue = "EffectsPickerSegue"
    }
    
    struct EffectsPicker {
        static let EffectsPickerCellIdentifier = "EffectsPickerCell"
    }
    
    struct EffectEditor {
        static let UserResizableViewGlobalInset: CGFloat =  5.0
        static let UserResizableViewDefaultMinWidth: CGFloat =  48.0
        
        static let UserResizableViewInteractiveBorderSize: CGFloat =  10.0
        static let StickerViewControlSize: CGFloat =  36.0
    }
    
    struct EditProfile {
        static let EditProfileControllerIdentifier = "EditProfileViewController"
    }
}