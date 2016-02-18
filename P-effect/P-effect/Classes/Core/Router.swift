//
//  Router.swift
//  TaggedImagesSwift
//
//  Created by Rumata on 1/30/16.
//  Copyright © 2016 AndrewPetrov. All rights reserved.
//

import Foundation

protocol Router: class {
    
    typealias Context
    
    func execute(context: Context)
    
}

protocol Presenter: class {
    
    weak var currentViewController: UIViewController! { get }
    
}

protocol FeedPresenter: Presenter {
    
    func goToFeed()
    
}

extension FeedPresenter {
    
    func goToFeed() {
        currentViewController.navigationController!.popViewControllerAnimated(true)
    }
}

protocol ProfilePresenter: Presenter {
    
    func goToProfile(user: User)
    
}

extension ProfilePresenter {
    
    func goToProfile(user: User) {
        let profileRouter = ProfileRouter(user: user)
        profileRouter.execute(currentViewController)
    }
    
}

protocol EditProfilePresenter: Presenter {
    
    func goToEditProfile()
    
}

extension EditProfilePresenter {
    
    func goToEditProfile() {
        let editProfileRouter = EditProfileRouter()
        editProfileRouter.execute(currentViewController)
    }
    
}

protocol AuthorizationPresenter: Presenter {
    
    func goToAuthorization()
    
}

extension AuthorizationPresenter {
    
    func goToAuthorization() {
        let authorizationRouter = AuthorizationRouter()
        authorizationRouter.execute(currentViewController)
    }
    
}

protocol PhotoEditorPresenter: Presenter {
    
    func goToPhotoEditor(image: UIImage)
    
}

extension PhotoEditorPresenter {
    
    func goToPhotoEditor(image: UIImage) {
        let photoEditorRouter = PhotoEditorRouter(image: image)
        photoEditorRouter.execute(currentViewController)
    }
    
}