//
//  EffectsPickerViewController.swift
//  P-effect
//
//  Created by Illya on 1/26/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit


class EffectsPickerViewController: UICollectionViewController {
    
    weak var delegate: PhotoEditorViewController?
    var model: EffectsPickerModel? {
        didSet {
            collectionView?.dataSource = model
        }
    }
    var groupsShown: Bool?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        SaverService.uploadEffects()
        groupsShown = true
        model = EffectsPickerModel()
        automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        collectionView?.superview?.layoutIfNeeded()
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if groupsShown == true {
            //TODO: change it to reload array with selected group of effects
            model?.effects = 10
            collectionView.reloadData()
            groupsShown = false
        } else if indexPath.row == 0 {
            //TODO: change it to reload array with groups
        model?.effects = 3
        groupsShown = true
        collectionView.reloadData()
        }
    }
}
