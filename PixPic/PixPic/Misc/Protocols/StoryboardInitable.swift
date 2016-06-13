//
//  StoryboardInitable.swift
//  PixPic
//
//  Created by AndrewPetrov on 2/17/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

protocol StoryboardInitable {
    
    static var storyboardName: String { get }
    
    static func create() -> Self
    
}

extension StoryboardInitable {
    
    static func create() -> Self {
        let identifier = String(Self)
        
        return UIStoryboard(name: storyboardName, bundle: nil).instantiateViewControllerWithIdentifier(identifier) as! Self
    }
    
}
