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
        
        setupCollectionView()
        setupAdapter()
    }
    
    // MARK: - Private methods
    private func setupCollectionView() {
        collectionView!.registerNib(
            EffectsGroupHeaderView.cellNib(),
            forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
            withReuseIdentifier: EffectsGroupHeaderView.identifier
        )        
        collectionView!.collectionViewLayout = EffectsLayout()
        collectionView!.dataSource = effectsPickerAdapter
    }
    
    private func setupAdapter() {
        locator.registerService(EffectsService())
        
        let effectsService: EffectsService = locator.getService()
        effectsService.loadEffects { [weak self] objects, error in
            guard let this = self else {
                return
            }
            if let objects = objects {
                this.effectsPickerAdapter.effectsGroups = objects.sort {
                    $0.effectsGroup.label > $1.effectsGroup.label
                }
                this.collectionView!.reloadData()
            }
        }
    }
    
    // MARK: - UICollectionViewDelegate
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        effectsPickerAdapter.effectImage(atIndexPath: indexPath) { [weak self] image, error in
            if error != nil {
                return
            }
            if let image = image {
                self?.delegate?.didChooseEffectFromPicket(image)
            }
        }
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension EffectsPickerViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            return CGSizeMake(collectionView.bounds.size.height, collectionView.bounds.size.height)
    }
    
}
