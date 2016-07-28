//
//  EffectsPickerViewController.swift
//  PixPic
//
//  Created by Illya on 1/26/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class StickersPickerViewController: UICollectionViewController {
    
    lazy var stickersPickerAdapter = StickersPickerAdapter()
    weak var delegate: PhotoEditorViewController?
    private weak var locator: ServiceLocator!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupAdapter()
    }
    
    func setLocator(locator: ServiceLocator) {
        self.locator = locator
    }
    
    // MARK: - Private methods
    private func setupCollectionView() {
        collectionView!.registerNib(
            StickersGroupHeaderView.cellNib,
            forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
            withReuseIdentifier: StickersGroupHeaderView.id
        )        
        collectionView!.collectionViewLayout = StickersLayout()
        collectionView!.dataSource = stickersPickerAdapter
    }
    
    private func setupAdapter() {
        let stickersService: StickersLoaderService = locator.getService()
        collectionView!.reloadData()
        stickersService.loadStickers() { [weak self] objects, error in
            guard let this = self else {
                return
            }
            if let objects = objects {
                this.stickersPickerAdapter.sortStickersGroups(objects)
                this.collectionView!.reloadData()
            }
        }
    }
    
    // MARK: - UICollectionViewDelegate
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        stickersPickerAdapter.stickerImage(atIndexPath: indexPath) { [weak self] image, error in
            if let image = image {
                self?.delegate?.didChooseStickerFromPicket(image)
            }
        }
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension StickersPickerViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
            let itemHeight = collectionView.bounds.size.height
            
            return CGSize(width: itemHeight, height: itemHeight)
    }
    
}
