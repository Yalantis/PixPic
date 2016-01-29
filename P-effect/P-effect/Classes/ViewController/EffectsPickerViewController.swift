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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        SaverService.uploadEffects()
        model = EffectsPickerModel()
        model?.downloadEffects{ [weak self] (completion) in
            if completion {
            self!.model?.groupsShown = true
            self?.collectionView?.reloadData()
            }
        }
        
        automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        collectionView?.superview?.layoutIfNeeded()
    }

    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let model = model
            else { return }
        if model.groupsShown == true {
            //TODO: change it to reload array with selected group of effects
            model.shownGroupNumber = indexPath.row
            collectionView.reloadData()
            model.groupsShown = false
        } else if indexPath.row == 0 {
            //TODO: change it to reload array with groups
            //        model?.effects = 3
            model.shownGroupNumber = nil
            model.groupsShown = true
            collectionView.reloadData()
        }
    }
    
}
