//
//  PhotoEditorRouter.swift
//  P-effect
//
//  Created by AndrewPetrov on 2/17/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class PhotoEditorRouter: AlertManagerDelegate, FeedPresenter {
    
    typealias Context = UIViewController
    
    private var image: UIImage!
    private(set) weak var locator: ServiceLocator!
    private(set) weak var currentViewController: UIViewController!
    
    init(image: UIImage, locator: ServiceLocator) {
        self.image = image
        self.locator = locator
    }
    
    func execute(context: UIViewController) {
        let photoEditorViewController = PhotoEditorViewController.create()
        photoEditorViewController.router = self
        photoEditorViewController.setLocator(locator)
        currentViewController = photoEditorViewController
        photoEditorViewController.model = PhotoEditorModel(image: image)
        context.navigationController!.pushViewController(photoEditorViewController, animated: false)
    }
    
}
