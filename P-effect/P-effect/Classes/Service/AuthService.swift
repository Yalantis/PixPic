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
        
        PFFacebookUtils.logInInBackgroundWithReadPermissions(["public_profile"]) { [unowned self] user, error in
            print("\(user)")

            if user!.isNew {
                print("new")
                

            } else if user == nil {
                print("nil")
            } else {
                print("\(user)")
                self.loadData()
            }
            
        }
    }
    
        func loadData() {
            let request = FBSDKGraphRequest(graphPath: "me", parameters: nil)
            request.startWithCompletionHandler { connection, result, error in
                if error != nil {
                    let userData = result as! [String: AnyObject]
                    let facebookID = userData["id"] as! String
                    let name = userData["name"] as! String
                    
                    let pictureURL = NSURL(string: "https://graph.facebook.com/\(facebookID)/picture?type=large&return_ssl_resources=1")
                    
                    print("\(name) \(facebookID)")
                    
                    
                }
            }
        }
}


//        
//        let login = FBSDKLoginManager()
//        login.logInWithReadPermissions(["public_profile"], fromViewController: fromViewController) { result, error in
//
//            if (error != nil) {
//                print("Process error")
//            } else if (result.isCancelled) {
//                print("Cancelled")
//            } else {
//                print("Logged in")
//                print("\(result.token)")
//                
//            }
//        }

