//
//  ReachabilityHelper.swift
//  P-effect
//
//  Created by AndrewPetrov on 2/3/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class ReachabilityService {
    
    private let reachability = try? Reachability.reachabilityForInternetConnection()
    
    func isReachable() -> Bool {
        return reachability?.isReachable() == true
    }
    
}