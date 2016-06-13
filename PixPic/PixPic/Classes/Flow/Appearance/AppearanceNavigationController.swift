//
//  AppearanceNavigationController.swift
//  PixPic
//
//  Created by anna on 3/14/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//


import Foundation
import UIKit

class AppearanceNavigationController: UINavigationController, UINavigationControllerDelegate, UINavigationBarDelegate {
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        
        interactivePopGestureRecognizer?.enabled = false
        delegate = self
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        interactivePopGestureRecognizer?.enabled = false
        delegate = self
    }
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        
        interactivePopGestureRecognizer?.enabled = false
        delegate = self
    }
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - UINavigationControllerDelegate
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        guard let appearanceContext = viewController as? NavigationControllerAppearanceContext else {
            return
        }
        
        setNavigationBarHidden(appearanceContext.prefersNavigationControllerBarHidden(self), animated: animated)
        setToolbarHidden(appearanceContext.prefersNavigationControllerToolbarHidden(self), animated: animated)
        applyAppearance(
            appearanceContext.preferredNavigationControllerAppearance(self),
            navigationItem: viewController.navigationItem,
            animated: animated
        )
    }
    
    // MARK: - Appearance Applying
    private var appliedAppearance: Appearance?
    
    private func applyAppearance(appearance: Appearance?, navigationItem: UINavigationItem?, animated: Bool) {
        if let appearance = appearance {
            appliedAppearance = appearance
            
            appearanceApplyingStrategy.apply(appearance, toNavigationController: self, navigationItem:  navigationItem, animated: animated)
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    var appearanceApplyingStrategy = AppearanceApplyingStrategy() {
        didSet {
            applyAppearance(appliedAppearance, navigationItem: topViewController?.navigationItem, animated: false)
        }
    }
    
    // MARK: - Apperanace Update
    func updateAppearanceForViewController(viewController: UIViewController) {
        if let context = viewController as? NavigationControllerAppearanceContext
            where viewController == topViewController && transitionCoordinator() == nil {
            setNavigationBarHidden(context.prefersNavigationControllerBarHidden(self), animated: true)
            setToolbarHidden(context.prefersNavigationControllerToolbarHidden(self), animated: true)
            applyAppearance(
                context.preferredNavigationControllerAppearance(self),
                navigationItem: viewController.navigationItem,
                animated: true
            )
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return appliedAppearance?.statusBarStyle ?? self.topViewController?.preferredStatusBarStyle()
            ?? super.preferredStatusBarStyle()
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return appliedAppearance != nil ? .Fade : super.preferredStatusBarUpdateAnimation()
    }
    
}
