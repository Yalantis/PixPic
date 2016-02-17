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
    lazy var effectsPickerAdapter = EffectsPickerModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAdapter()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        collectionView!.superview?.layoutIfNeeded()
    }
    
    // MARK: - Private methods
    private func setupAdapter() {
        collectionView!.dataSource = effectsPickerAdapter
        collectionView!.delegate = effectsPickerAdapter
        
        EffectsService().loadEffects() { [weak self] objects, error in
            if let objects = objects {
                self?.effectsPickerAdapter.effectsGroups = objects.sort {
                    $0.effectsGroup.label > $1.effectsGroup.label
                }
                self?.collectionView!.reloadData()
            }
        }
    }
    
}
