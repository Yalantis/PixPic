//
//  ValidationService.swift
//  P-effect
//
//  Created by Illya on 1/22/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import UIKit

class ValidationService: NSObject {
    class func valdateUserName(userName: String, completion:(Bool)->()){
        if userName
        let query = PFUser.query()?.whereKey("username", equalTo: userName)
        query?.getFirstObjectInBackgroundWithBlock({ (object, error) -> Void in
            if object != nil {
                completion(true)
                print("username exists")
            } else {
                completion(false)
            }
        })
    }

}
