//
//  Constants.swift
//  InstaFeedObserver
//
//  Created by Jack Lapin on 13.11.15.
//  Copyright © 2015 Jack Lapin. All rights reserved.
//


struct Constants {

    struct ParseApplicationId {
        //add this 2 keys from 'develop'. also add fabric script to build phases, url scheme and FacebookAppID to plist
        static let AppID = ""
        static let ClientKey = ""
    }

    struct NotificationName {

        static let newPostIsUploaded = "newPostIsUploaded"
        static let newPostIsReceaved = "newPostIsReceaved"
        static let followersListIsUpdated = "followersListIsUpdated"
        static let likersListIsUpdated = "likersListIsUpdated"

    }

    struct BaseDimensions {

        static let toolBarHeight: CGFloat = 66
        static let navBarWithStatusBarHeight: CGFloat = 64

    }

    struct FileSize {

        static let maxUploadSizeBytes = 10485760

    }

    struct Path {

        static let documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        static let tmp = NSTemporaryDirectory()

    }

    struct Storyboard {

        static let authorization = "Authorization"
        static let feed = "Feed"
        static let photoEditor = "PhotoEditor"
        static let profile = "Profile"
        static let launchScreen = "LaunchScreen"
        static let settings = "Settings"

    }

    struct UserDefaultsKeys {

        static let remoteNotifications = "remoteNotifications"
        static let followedPosts = "followedPosts"

    }

    struct UserKey {

        static let avatar = "avatar"
        static let id = "objectId"

    }

    struct Profile {

        static let toastActivityDuration: NSTimeInterval = 5
        static let headerHeight: CGFloat = 322
        static let avatarImageCornerRadius: CGFloat = 95.5
        static let avatarImagePlaceholderName = "profile_placeholder.png"
        static let possibleInsets: CGFloat = 45
        static let settingsButtonImage = "icEdit"
        static let navigationTitle = "Profile"

    }

    struct DataSource {

        static let queryLimit = 10 as Int

    }

    struct ValidationErrors {

        static let wrongLenght = "Length of the username must be 3-30 characters long"
        static let alreadyExist = "Username already exists"
        static let spaceInBegining = "Username can't start with spaces"
        static let characterSet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789" +
        "абвгдеёжзийклмнопрстуфхцчшщъыьэюяАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ "
        static let spaceInEnd = "Username can't end with spaces"
        static let numbersAndSymbolsInUsername = "Username has to contain only letters and numbers"
        static let twoConsecutiveSpaces = "Username can't contain two consecutive spaces"
        static let minUserName = 3
        static let maxUserName = 30
        static let whiteSpace: Character = " "

    }

    struct PhotoEditor {

        static let imageViewControllerSegue = "imageViewControllerSegue"
        static let stickersPickerSegue = "stickersPickerSegue"

    }

    struct StickerPicker {

        static let stickerPickerCellIdentifier = "StickerPickerCell"

    }

    struct StickerEditor {

        static let userResizableViewGlobalOffset: CGFloat = 5
        static let stickerViewControlSize: CGFloat = 36

    }

    struct EditProfile {

        static let navigationTitle = "Edit Profile"

    }

    struct Attributes {

        static let postsCount = "postsCount"
        static let followStatusByCurrentUser = "followStatusByCurrentUser"
        static let likeStatusByCurrentUser = "likeStatusByCurrentUser"
        static let likesCount = "likesCount"
        static let likers = "likers"
        static let comments = "comments"
        static let followers = "followers"
        static let following = "following"
        static let followersCount = "followersCount"
        static let followingCount = "followingCount"

    }

    struct ActivityKey {

        static let fromUser = "fromUser"
        static let toUser = "toUser"
        static let toPost = "toPost"
        static let type = "type"

    }

    struct Feed {

        static let navigationTitle = "PixPic"

    }

    struct Settings {

        static let navigationTitle = "Settings"

    }

    struct Network {
        
        static let timeoutTimeInterval: NSTimeInterval = 5

    }

    struct StickerCell {

        static let size = CGSize(width: 105, height: 105)
        
    }
    
}
