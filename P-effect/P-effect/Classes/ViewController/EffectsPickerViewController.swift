//
//  EffectsPickerViewController.swift
//  P-effect
//
//  Created by Illya on 1/26/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class EffectsPickerViewController: UICollectionViewController {
    
    lazy var effectsPickerAdapter = EffectsPickerAdapter()
    lazy var locator = ServiceLocator()
    weak var delegate: PhotoEditorViewController?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAdapter()
        collectionView!.registerNib(EffectsGroupHeaderView.nib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: EffectsGroupHeaderView.identifier)
        
        collectionView!.collectionViewLayout = EffectsLayout()
    }
    
    // MARK: - Private methods
    private func setupAdapter() {
        collectionView!.dataSource = effectsPickerAdapter
        
        locator.registerService(EffectsService())
        
        let effectsService: EffectsService = locator.getService()
        effectsService.loadEffects { [weak self] objects, error in
            if let objects = objects {
                self?.effectsPickerAdapter.effectsGroups = objects.sort {
                    $0.effectsGroup.label > $1.effectsGroup.label
                }
                self?.collectionView!.reloadData()
            }
        }
    }
    
    // MARK: - UICollectionViewDelegate
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        effectsPickerAdapter.effectImageAtIndexPath(indexPath) { [unowned self] image, error in
            if error != nil {
                return
            }
            if let image = image {
                self.delegate?.didChooseEffectFromPicket(image)
            }
        }
    }
    
}

extension EffectsPickerViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            return CGSizeMake(collectionView.bounds.size.height, collectionView.bounds.size.height)
    }
    
}
