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
            model?.downloadEffects{ [weak self] completion in
                if completion {
                    self?.collectionView?.reloadData()
                }
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
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let model = model else {
            return
        }
        model.effectImageAtIndexPath(indexPath) { [weak self] image, error in
            if error != nil {
                return
            }
            if let image = image {
                self?.delegate?.didChooseEffectFromPicket(image)
            }
        }
    }
    
}

