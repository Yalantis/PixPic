//
//  PhotoEditorRouter.swift
//  P-effect
//
//  Created by AndrewPetrov on 2/17/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class PhotoEditorRouter {
    
    private(set) weak var currentViewController: UIViewController!
    private var image: UIImage!
    
    init(image: UIImage) {
        self.image = image
    }
    
}

extension PhotoEditorRouter: FeedPresenter {
    typealias Context = UIViewController
    
    func execute(context: UIViewController) {
        
        let photoEditorViewController = PhotoEditorViewController.create()
        photoEditorViewController.router = self
        currentViewController = photoEditorViewController
        photoEditorViewController.model = PhotoEditorModel(image: image)
        context.navigationController!.pushViewController(photoEditorViewController, animated: false)
    }
    
}
