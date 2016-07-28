//
//  ServiceLocator.swift
//  PixPic
//
//  Created by Jack Lapin on 16.02.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

public class ServiceLocator {
    
    private var registry: [String: Any] = [:]
    
    public init() {}
    
    func registerService<T>(service: T) {
        let key = "\(T.self)"
        registry[key] = service
    }
    
    public func getService<T>() -> T! {
        let key = "\(T.self)"
        
        return registry[key] as! T
    }
    
}
