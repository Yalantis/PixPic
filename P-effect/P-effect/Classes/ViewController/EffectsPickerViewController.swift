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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView!.registerNib(EffectsGroupHeaderView.cellNib(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: EffectsGroupHeaderView.identifier)
        
        collectionView!.collectionViewLayout = EffectsLayout()
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        model!.effectImageAtIndexPath(indexPath) { [unowned self] image, error in
            if error != nil {
                return
            }
            if let image = image {
                self.delegate?.didChooseEffectFromPicket(image)
            }
        }
    }
    
}

