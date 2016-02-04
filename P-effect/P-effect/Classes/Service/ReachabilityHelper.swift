//
//  ReachabilityHelper.swift
//  P-effect
//
//  Created by AndrewPetrov on 2/3/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class ReachabilityHelper {
    
    private static let reachability: Reachability? = try? Reachability.reachabilityForInternetConnection()
    
    static func isInternetAccessAvailable(showNotification showNotification: Bool = true) -> Bool {
        guard let reachability = ReachabilityHelper.reachability where reachability.isReachable() else {
            if showNotification {
                AlertService.simpleAlert("No internet connection")
            }
            
            return false
        }
        
        return true
    }
    
}