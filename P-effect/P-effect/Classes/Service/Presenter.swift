//
//  Router.swift
//  P-effect
//
//  Created by anna on 1/18/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

private let appRouterAnimationDelay = 0.3
private let appRouterAnimationDuration = 0.45

typealias Handler = () -> Void

protocol Router: class {
    
    typealias Context
    
    func execute(context: Context)
    
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
        return  {
            self.showFeed()
        }
    }
    
    func showFeed() {
        currentViewController.navigationController!.popToRootViewControllerAnimated(true)
    }
}

protocol ProfilePresenter: PresenterType {
    
    func showProfile(user: User)
    
}

extension ProfilePresenter {
    
    func showProfile(user: User) {
        let profileRouter = ProfileRouter(user: user, locator: locator)
        let appearanceController = currentViewController.navigationController as? AppearanceNavigationController
        guard let navigationController = appearanceController else {
            return
        }
        profileRouter.execute(navigationController)
    }
    
    func showProfile(userId: String) {
        let profileRouter = ProfileRouter(userId: userId, locator: locator)
        profileRouter.execute(currentViewController.navigationController!)
    }
    
}

protocol EditProfilePresenter: PresenterType {
    
    func showEditProfile()
    
}

extension EditProfilePresenter {
    
    func showEditProfile() {
        let editProfileRouter = EditProfileRouter(locator: locator)
        let appearanceController = currentViewController.navigationController as? AppearanceNavigationController
        guard let navigationController = appearanceController else {
            return
        }
        editProfileRouter.execute(navigationController)
    }
    
}

protocol AuthorizationPresenter: PresenterType {
    
    func showAuthorization()
    
}

extension AuthorizationPresenter {
    
    func showAuthorization() {
        let authorizationRouter = AuthorizationRouter(locator: locator)
        let appearanceController = currentViewController.navigationController as? AppearanceNavigationController
        guard let navigationController = appearanceController else {
            return
        }
        authorizationRouter.execute(navigationController)
    }
    
}

protocol PhotoEditorPresenter: PresenterType {
    
    func showPhotoEditor(image: UIImage)
    
}

extension PhotoEditorPresenter {
    
    func showPhotoEditor(image: UIImage) {
        let photoEditorRouter = PhotoEditorRouter(image: image, locator: locator)
        let appearanceController = currentViewController.navigationController as? AppearanceNavigationController
        guard let navigationController = appearanceController else {
            return
        }
        photoEditorRouter.execute(navigationController)
    }
    
}

protocol SettingsPresenter: PresenterType {
    
    func showSettings()
    
}

extension SettingsPresenter {
    
    func showSettings() {
        let settingsRouter = SettingsRouter(locator: locator)
        let appearanceController = currentViewController.navigationController as? AppearanceNavigationController
        guard let navigationController = appearanceController else {
            return
        }
        settingsRouter.execute(navigationController)
    }
    
}

protocol CredentialsPresenter: PresenterType {
    
    func showCredentials()
    
}

extension CredentialsPresenter {
    
    func showCredentials() {
        let credentialsRouter = CredentialsRouter(locator: locator)
        let appearanceController = currentViewController.navigationController as? AppearanceNavigationController
        guard let navigationController = appearanceController else {
            return
        }
        credentialsRouter.execute(navigationController)
    }
    
}
protocol FollowersListPresenter: PresenterType {
    
    func showFollowersList(user: User, followType: FollowType)
    
}

extension FollowersListPresenter {
    
    func showFollowersList(user: User, followType: FollowType) {
        let followersListRouter = FollowersListRouter(user: user, followType: followType, locator: locator)
        let appearanceController = currentViewController.navigationController as? AppearanceNavigationController
        guard let navigationController = appearanceController else {
            return
        }
        followersListRouter.execute(navigationController)
    }
    
}
