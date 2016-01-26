//
//  PhotoEditorViewController.swift
//  P-effect
//
//  Created by Illya on 1/25/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class PhotoEditorViewController: UIViewController {
    
    @IBOutlet weak var effectsPickerContainer: UIView!
    @IBOutlet weak var imageContainer: UIView!
    
    var model: PhotoEditorModel!

    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var leftToolbarButton: UIBarButtonItem!
    @IBOutlet weak var rightToolbarButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
       setupView()
    }

    func setupView() {
//        if let image = imageModel {
//            postImage.image = image
//        }
        
        var size = imageContainer.bounds.size
        size.height = size.width
        imageContainer.frame.size = size
        
        leftToolbarButton.width = UIScreen.mainScreen().bounds.width*0.5
        rightToolbarButton.width = UIScreen.mainScreen().bounds.width*0.5
    }

    @IBAction func postEditedImage(sender: AnyObject) {
        
    }
    
    @IBAction func saveToImageLibrary(sender: AnyObject) {
        
    }
    
}
