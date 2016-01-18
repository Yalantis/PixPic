//
//  AuthorizationViewController.swift
//  P-effect
//
//  Created by anna on 1/16/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class AuthorizationViewController: UIViewController {

    @IBAction private func logInWithFBButtonTapped() {
        AuthService().logIn(self)
    }

}
