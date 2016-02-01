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

        automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        collectionView?.superview?.layoutIfNeeded()
    }

}
