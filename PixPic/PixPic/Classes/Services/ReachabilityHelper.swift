//
//  ReachabilityHelper.swift
//  PixPic
//
//  Created by AndrewPetrov on 2/3/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class ReachabilityHelper {
    
    private static let reachability = try? Reachability.reachabilityForInternetConnection()
    
    static func isReachable() -> Bool {
        return reachability?.isReachable() == true
    }
    
}