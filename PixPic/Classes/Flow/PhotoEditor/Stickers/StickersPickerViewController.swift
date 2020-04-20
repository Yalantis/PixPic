//
//  EffectsPickerViewController.swift
//  PixPic
//
//  Created by Illya on 1/26/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class StickersPickerViewController: UICollectionViewController {

    fileprivate lazy var stickersPickerAdapter: StickersPickerAdapter = {
        let adapter = StickersPickerAdapter()
        adapter.currentHeaderIndexChangingHandler = { index in
            self.layoutAnimator.switchLayout(forCurrentGroupIndex: index)
        }
        return adapter
    }()

    weak var delegate: PhotoEditorViewController?
    fileprivate weak var locator: ServiceLocator!
    fileprivate lazy var layoutAnimator: StickersPickerLayoutAnimator =
        StickersPickerLayoutAnimator(collectionView: self.collectionView!)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        setupAdapter()
        automaticallyAdjustsScrollViewInsets = false
    }

    func setLocator(_ locator: ServiceLocator) {
        self.locator = locator
    }

    // MARK: - Private methods
    fileprivate func setupCollectionView() {
        collectionView!.registerNib(
            StickersGroupHeaderView.cellNib,
            forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
            withReuseIdentifier: StickersGroupHeaderView.id
        )
        collectionView!.dataSource = stickersPickerAdapter
        collectionView!.bounces = false
        layoutAnimator.switchLayout(forCurrentGroupIndex: nil)
    }

    fileprivate func setupAdapter() {
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
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        stickersPickerAdapter.stickerImage(atIndexPath: indexPath) { [weak self] image, error in
            if let image = image {
                self?.delegate?.didChooseStickerFromPicket(image)
            }
        }
    }

}
