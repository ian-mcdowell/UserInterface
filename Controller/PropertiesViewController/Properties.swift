//
//  Properties.swift
//  UserInterface
//
//  Created by Ian McDowell on 2/28/17.
//  Copyright © 2017 Ian McDowell. All rights reserved.
//

import Foundation

public typealias PropertiesDeferredCallback = (_ callback: @escaping (_ properties: [PropertySection]) -> Void) -> Void
public class Properties {
    
    internal var properties: [PropertySection]?
    internal var deferred: PropertiesDeferredCallback?
    
    private init(properties: [PropertySection]) {
        self.properties = properties
    }
    
    private init(deferred: @escaping PropertiesDeferredCallback) {
        self.deferred = deferred
    }
    
    public static func properties(_ properties: [PropertySection]) -> Properties {
        return Properties.init(properties: properties)
    }
    
    public static func deferred(_ deferred: @escaping PropertiesDeferredCallback) -> Properties {
        return Properties.init(deferred: deferred)
    }
    
    public static func empty() -> Properties {
        return Properties.init(properties: [])
    }
    
    public func appending(_ properties: [PropertySection]) -> Properties {
        self.properties?.append(contentsOf: properties)
        return self
    }
}
