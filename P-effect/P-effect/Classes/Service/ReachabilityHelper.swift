//
//  ReachabilityHelper.swift
//  P-effect
//
//  Created by AndrewPetrov on 2/3/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

class ReachabilityHelper {
    
    static func isInternetAccessAvailable() -> Bool {
        let reachability: Reachability
        do {
            reachability = try Reachability.reachabilityForInternetConnection()
        } catch {
            print("Unable to create Reachability")
            
            return false
        }
        if !reachability.isReachable() {
            let message = reachability.currentReachabilityStatus.description
            AlertService.simpleAlert(message)
            
            return false
        } else {
            return true
        }
    }
    
}