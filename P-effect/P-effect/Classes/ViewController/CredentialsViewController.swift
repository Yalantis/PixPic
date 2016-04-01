//
//  CredentialsViewController.swift
//  P-effect
//
//  Created by AndrewPetrov on 3/1/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

private let title = "Credentials and Policies"

final class CredentialsViewController: UIViewController, StoryboardInitable, NavigationControllerAppearanceContext {
    
    static let storyboardName = Constants.Storyboard.Settings
    
    var router: protocol<FeedPresenter, AlertManagerDelegate>!
    private weak var locator: ServiceLocator!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = title
    }
    
    // MARK: - Setup methods
    func setLocator(locator: ServiceLocator) {
        self.locator = locator
    }
    
}