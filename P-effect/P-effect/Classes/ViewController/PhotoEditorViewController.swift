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
    @IBOutlet weak var leftToolbarButton: UIBarButtonItem!
    @IBOutlet weak var rightToolbarButton: UIBarButtonItem!
    
    var model: PhotoEditorModel!
    var effectsPickerController: EffectsPickerViewController?
    var imageController: ImageViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       setupView()
    }

    func setupView() {
        var size = imageContainer.frame.size
        size.width = UIScreen.mainScreen().bounds.width
        size.height = size.width
        imageContainer.frame.size = size
        size.height = effectsPickerContainer.frame.height
        effectsPickerContainer.frame.size = size
        
        leftToolbarButton.width = UIScreen.mainScreen().bounds.width*0.5
        rightToolbarButton.width = UIScreen.mainScreen().bounds.width*0.5
    }

    @IBAction func postEditedImage(sender: AnyObject) {
        
    }
    
    @IBAction func saveToImageLibrary(sender: AnyObject) {
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch segue.identifier! {
            case Constants.PhotoEditor.ImageViewControllerSegue:
                imageController = segue.destinationViewController as? ImageViewController
                break
            case Constants.PhotoEditor.EffectsPickerSegue:
                effectsPickerController = segue.destinationViewController as? EffectsPickerViewController
                break
            default:
                break
        }
        
        super.prepareForSegue(segue, sender: sender)
    }
}
