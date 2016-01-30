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
        
        model = EffectsPickerModel()
        model?.downloadEffects{ [weak self] completion in
            if completion {
                self!.model?.groupsShown = true
                self?.collectionView?.reloadData()
            }
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        collectionView?.superview?.layoutIfNeeded()
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            return CGSizeMake(collectionView.bounds.size.height, collectionView.bounds.size.height)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
            return UIEdgeInsetsMake(-66, 0, 0, 0);
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let model = model
            else { return }
        if model.groupsShown == true {
            model.shownGroupNumber = indexPath.row
            model.groupsShown = false
            collectionView.reloadData()
        } else if indexPath.row == 0 {
            model.shownGroupNumber = nil
            model.groupsShown = true
            collectionView.reloadData()
        } else {
            model.effectImageAtIndexPath(indexPath) { [weak self] image in
                self?.delegate?.didChooseEffectFromPicket(image)
            }
        }
    }
}
