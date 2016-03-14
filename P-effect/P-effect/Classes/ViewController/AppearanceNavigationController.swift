//
//  AppearanceNavigationController.swift
//  P-effect
//
//  Created by anna on 3/14/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//


import Foundation
import UIKit

public class AppearanceNavigationController: UINavigationController, UINavigationControllerDelegate, UINavigationBarDelegate {
    
    public required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
        interactivePopGestureRecognizer?.enabled = false
        delegate = self
    }
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        interactivePopGestureRecognizer?.enabled = false
        delegate = self
    }
    
    override public init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        interactivePopGestureRecognizer?.enabled = false
        delegate = self
    }
    
    public convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    // MARK: - UINavigationControllerDelegate
    
    public func navigationController(
        navigationController: UINavigationController,
        willShowViewController viewController: UIViewController, animated: Bool
        ) {
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
            
            // interactive gesture requires more complex logic.
            guard let coordinator = viewController.transitionCoordinator() where coordinator.isInteractive() else {
                return
            }
            
            coordinator.animateAlongsideTransition({ _ in }, completion: { context in
                if context.isCancelled(), let appearanceContext = self.topViewController as? NavigationControllerAppearanceContext {
                    // hiding navigation bar & toolbar within interaction completion will result into inconsistent UI state
                    self.setNavigationBarHidden(appearanceContext.prefersNavigationControllerBarHidden(self), animated: animated)
                    self.setToolbarHidden(appearanceContext.prefersNavigationControllerToolbarHidden(self), animated: animated)
                }
            })
            
            coordinator.notifyWhenInteractionEndsUsingBlock { context in
                let key = UITransitionContextFromViewControllerKey
                if context.isCancelled(),
                    let viewController = context.viewControllerForKey(key),
                    from = viewController as? NavigationControllerAppearanceContext
                {
                    // changing navigation bar & toolbar appearance within animate completion will result into UI glitch
                    self.applyAppearance(
                        from.preferredNavigationControllerAppearance(self),
                        navigationItem: viewController.navigationItem,
                        animated: true
                    )
                }
            }
    }
    
    // MARK: - Appearance Applying
    
    private var appliedAppearance: Appearance?
    
    private func applyAppearance(appearance: Appearance?, navigationItem: UINavigationItem?, animated: Bool) {
        if appearance != nil && appliedAppearance != appearance {
            appliedAppearance = appearance
            
            appearanceApplyingStrategy.apply(appearance, toNavigationController: self, navigationItem:  navigationItem, animated: animated)
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    public var appearanceApplyingStrategy = AppearanceApplyingStrategy() {
        didSet {
            applyAppearance(appliedAppearance, navigationItem: topViewController?.navigationItem, animated: false)
        }
    }
    
    // MARK: - Apperanace Update
    
    func updateAppearanceForViewController(viewController: UIViewController) {
        if let
            context = viewController as? NavigationControllerAppearanceContext
            where
            viewController == topViewController && transitionCoordinator() == nil
        {
            setNavigationBarHidden(context.prefersNavigationControllerBarHidden(self), animated: true)
            setToolbarHidden(context.prefersNavigationControllerToolbarHidden(self), animated: true)
            applyAppearance(
                context.preferredNavigationControllerAppearance(self),
                navigationItem: viewController.navigationItem,
                animated: true
            )
        }
    }
    
    public func updateAppearance() {
        if let top = topViewController {
            updateAppearanceForViewController(top)
        }
    }
    
    override public func preferredStatusBarStyle() -> UIStatusBarStyle {
        return appliedAppearance?.statusBarStyle ?? self.topViewController?.preferredStatusBarStyle()
            ?? super.preferredStatusBarStyle()
    }
    
    override public func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return appliedAppearance != nil ? .Fade : super.preferredStatusBarUpdateAnimation()
    }
    
}
