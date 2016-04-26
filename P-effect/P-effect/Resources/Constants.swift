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
        static let NewPostIsUploaded = "NewPostIsUploaded"
        static let FollowersListIsUpdated = "FollowersListIsUpdated"
    }
    
    struct BaseDimensions {
        static let ToolBarHeight: CGFloat = 50
        static let NavBarWithStatusBarHeight: CGFloat = 64
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
        static let FollowedPosts = "FollowedPosts"
    }
    
    struct UserKey {
        static let Avatar = "avatar"
        static let Id = "objectId"
    }
    
    struct Profile {
        static let ToastActivityDuration: NSTimeInterval = 5
        static let HeaderHeight: CGFloat = 322
        static let AvatarImageCornerRadius: CGFloat = 95.5
        static let AvatarImagePlaceholderName = "profile_placeholder.png"
        static let PossibleInsets: CGFloat = 45
        static let SettingsButtonImage = "icon_edit"
        static let NavigationTitle = "Profile"
    }
    
    struct DataSource {
        static let QueryLimit = 10 as Int
    }
    
    struct ValidationErrors {
        static let WrongLenght = "Length of the username has to be more then 3 and less then 30 characters long" as String
        static let AlreadyExist = "Username already exists" as String
        static let SpaceInBegining = "Username can't start with spaces" as String
        static let CharacterSet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789абвгдеёжзийклмнопрстуфхцчшщъыьэюяАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ " as String
        static let SpaceInEnd = "Username can't end with spaces" as String
        static let NumbersAndSymbolsInUsername = "Username has to contain only letters and numbers" as String
        static let TwoSpacesInRow = "Username can't contain more than one space per row" as String
        static let MinUserName: Int = 3
        static let MaxUserName: Int = 30
        static let WhiteSpace: Character = " "
    }
    
    struct PhotoEditor {
        static let ImageViewControllerSegue = "ImageViewControllerSegue"
        static let StickersPickerSegue = "StickersPickerSegue"
    }
    
    struct StickerPicker {
        static let StickerPickerCellIdentifier = "StickerPickerCell"
    }
    
    struct StickerEditor {
        static let UserResizableViewGlobalOffset: CGFloat = 5
        static let UserResizableViewDefaultMinWidth: CGFloat = 48
        static let StickerViewControlSize: CGFloat = 36
    }
    
    struct EditProfile {
        static let EditProfileControllerIdentifier = "EditProfileViewController"
        static let NavigationTitle = "Edit Profile"
    }
    
    struct Attributes {
        static let PostsCount = "postsCount"
        static let IsFollowedByCurrentUser = "isFollowedByCurrentUser"
        static let IsLikedByCurrentUser = "isLikedByCurrentUser"
        static let PhotosCount = "photosCount"
        static let LikesCount = "likesCount"
        static let Likers = "likers"
        static let Followers = "followers"
        static let Following = "following"
        static let FollowersCount = "followersCount"
        static let FollowingCount = "followingCount"
    }
    
    struct ActivityKey {
        static let FromUser = "fromUser"
        static let ToUser = "toUser"
        static let Type = "type"
        static let Content = "content"
    }
    
    struct Feed {
        static let NavigationTitle = "P-effect"
    }
    
    struct Settings {
        static let NavigationTitle = "Settings"
    }
    
}