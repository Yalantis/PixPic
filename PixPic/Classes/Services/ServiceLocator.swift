//
//  ServiceLocator.swift
//  PixPic
//
//  Created by Jack Lapin on 16.02.16.
//  Copyright © 2016 Yalantis. All rights reserved.
//

open class ServiceLocator {

    fileprivate var registry: [String: Any] = [:]

    public init() {}

    func registerService<T>(_ service: T) {
        let key = "\(T.self)"
        registry[key] = service
    }

    open func getService<T>() -> T! {
        let key = "\(T.self)"

        return registry[key] as! T
    }

}
