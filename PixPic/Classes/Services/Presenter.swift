//
//  Router.swift
//  PixPic
//
//  Created by anna on 1/18/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

private let appRouterAnimationDelay: TimeInterval = 0.3
private let appRouterAnimationDuration: TimeInterval = 0.45

typealias Handler = () -> Void

protocol Router: class {

    associatedtype Context

    func execute(_ context: Context)
    func execute(_ context: Context, userInfo: AnyObject?)

}

protocol PresenterType: class {

    weak var locator: ServiceLocator! { get }
    weak var currentViewController: UIViewController! { get }

}

protocol FeedPresenter: PresenterType {

    var showFeedAction: Handler { get }

    func showFeed()

}

extension FeedPresenter {

    var showFeedAction: Handler {
        return {
            self.showFeed()
        }
    }

    func showFeed() {
        currentViewController.navigationController?.viewControllers.first?.navigationItem.title =
            Constants.Feed.navigationTitle
        currentViewController.navigationController?.popToRootViewController(animated: true)
    }

}

protocol ProfilePresenter: PresenterType {

    func showProfile(_ user: User)

}

extension ProfilePresenter {

    func showProfile(_ user: User) {
        let profileRouter = ProfileRouter(user: user, locator: locator)
        if let appearanceController = currentViewController.navigationController as? AppearanceNavigationController {
            profileRouter.execute(appearanceController)
        }
    }

    func showProfile(_ userId: String) {
        let profileRouter = ProfileRouter(userId: userId, locator: locator)
        if let appearanceController = currentViewController.navigationController as? AppearanceNavigationController {
            profileRouter.execute(appearanceController)
        }
    }

    func showMyProfileWithPost(_ postId: String) {
        let profileRouter = ProfileRouter(locator: locator)
        if let currentViewController = currentViewController as? ProfileViewController, currentViewController.user == User.currentUser() {
            currentViewController.setUserInfo(postId)
        } else if let appearanceController =
            currentViewController.navigationController as? AppearanceNavigationController {
            profileRouter.execute(appearanceController, userInfo: postId)
        }
    }

}

protocol EditProfilePresenter: PresenterType {

    func showEditProfile()

}

extension EditProfilePresenter {

    func showEditProfile() {
        let editProfileRouter = EditProfileRouter(locator: locator)
        if let appearanceController = currentViewController.navigationController as? AppearanceNavigationController {
            editProfileRouter.execute(appearanceController, userInfo:  nil)
        }
    }

}

protocol AuthorizationPresenter: PresenterType {

    func showAuthorization()

}

extension AuthorizationPresenter {

    func showAuthorization() {
        let authorizationRouter = AuthorizationRouter(locator: locator)
        if let appearanceController = currentViewController.navigationController as? AppearanceNavigationController {
            authorizationRouter.execute(appearanceController, userInfo:  nil)
        }
    }

}

protocol PhotoEditorPresenter: PresenterType {

    func showPhotoEditor(_ image: UIImage)

}

extension PhotoEditorPresenter {

    func showPhotoEditor(_ image: UIImage) {
        let photoEditorRouter = PhotoEditorRouter(image: image, locator: locator)
        if let appearanceController = currentViewController.navigationController as? AppearanceNavigationController {
            photoEditorRouter.execute(appearanceController)
        }
    }

}

protocol SettingsPresenter: PresenterType {

    func showSettings()

}

extension SettingsPresenter {

    func showSettings() {
        let settingsRouter = SettingsRouter(locator: locator)
        if let appearanceController = currentViewController.navigationController as? AppearanceNavigationController {
            settingsRouter.execute(appearanceController, userInfo:  nil)
        }
    }

}

protocol FollowersListPresenter: PresenterType {

    func showFollowersList(_ user: User, followType: FollowType)

}

extension FollowersListPresenter {

    func showFollowersList(_ user: User, followType: FollowType) {
        let followersListRouter = FollowersListRouter(user: user, followType: followType, locator: locator)
        if let appearanceController = currentViewController.navigationController as? AppearanceNavigationController {
            followersListRouter.execute(appearanceController, userInfo:  nil)
        }
    }

}
