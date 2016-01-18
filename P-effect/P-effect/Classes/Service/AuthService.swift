//
//  AuthService.swift
//  P-effect
//
//  Created by anna on 1/18/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class AuthService: NSObject {
    
    func logIn(fromViewController: UIViewController) {
        let login = FBSDKLoginManager()
        login.logInWithReadPermissions(["public_profile"], fromViewController: fromViewController) { result, error in
            if (error != nil) {
                print("Process error")
            } else if (result.isCancelled) {
                print("Cancelled")
            } else {
                print("Logged in")
            }
        }
    }

}
