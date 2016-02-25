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

protocol Presenter: class {
    
    weak var locator: ServiceLocator! { get set }
    
    weak var currentViewController: UIViewController! { get }
    
}

protocol FeedPresenter: Presenter {
    
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

protocol ProfilePresenter: Presenter {
    
    func showProfile(user: User)
    
}

extension ProfilePresenter {
    
    func showProfile(user: User) {
        let profileRouter = ProfileRouter(user: user)
        profileRouter.locator = locator
        profileRouter.execute(currentViewController)
    }
    
}

protocol EditProfilePresenter: Presenter {
    
    func showEditProfile()
    
}

extension EditProfilePresenter {
    
    func showEditProfile() {
        let editProfileRouter = EditProfileRouter()
        editProfileRouter.locator = locator
        editProfileRouter.execute(currentViewController)
    }
    
}

protocol AuthorizationPresenter: Presenter {
    
    func showAuthorization()
    
}

extension AuthorizationPresenter {
    
    func showAuthorization() {
        let authorizationRouter = AuthorizationRouter()
        authorizationRouter.locator = locator
        authorizationRouter.execute(currentViewController)
    }
    
}

protocol PhotoEditorPresenter: Presenter {
    
    func showPhotoEditor(image: UIImage)
    
}

extension PhotoEditorPresenter {
    
    func showPhotoEditor(image: UIImage) {
        let photoEditorRouter = PhotoEditorRouter(image: image)
        photoEditorRouter.locator = locator
        photoEditorRouter.execute(currentViewController)
    }
    
}
