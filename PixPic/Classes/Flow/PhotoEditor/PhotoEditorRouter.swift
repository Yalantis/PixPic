//
//  PhotoEditorRouter.swift
//  PixPic
//
//  Created by AndrewPetrov on 2/17/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class PhotoEditorRouter: AlertManagerDelegate, FeedPresenter {

    fileprivate var image: UIImage!
    fileprivate(set) weak var locator: ServiceLocator!
    fileprivate(set) weak var currentViewController: UIViewController!

    init(image: UIImage, locator: ServiceLocator) {
        self.image = image
        self.locator = locator
    }

    func execute(_ context: AppearanceNavigationController) {
        let photoEditorViewController = PhotoEditorViewController.create()
        photoEditorViewController.setRouter(self)
        photoEditorViewController.setLocator(locator)
        currentViewController = photoEditorViewController
        photoEditorViewController.setModel(PhotoEditorModel(image: image))
        context.pushViewController(photoEditorViewController, animated: true)
    }

}
