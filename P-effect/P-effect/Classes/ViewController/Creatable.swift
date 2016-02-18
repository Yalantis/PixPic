//
//  Creatable.swift
//  P-effect
//
//  Created by AndrewPetrov on 2/17/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

protocol Creatable {
    
    static func create() -> Self
    
}

extension Creatable {
    
    static func create() -> Self {
        let identifier = String(Self)
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier(identifier) as! Self
    }
    
}
