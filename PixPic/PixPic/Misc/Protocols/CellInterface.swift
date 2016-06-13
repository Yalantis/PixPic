//
//  CellInterface.swift
//  PixPic
//
//  Created by AndrewPetrov on 2/17/16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

import Foundation

protocol CellInterface {
    
    static var id: String { get }
    
    static var cellNib: UINib { get }
    
}

extension CellInterface {
    
    static var id: String {
        return String(Self)
    }
    
    static var cellNib: UINib {
        return UINib(nibName: id, bundle: nil)
    }
    
}
