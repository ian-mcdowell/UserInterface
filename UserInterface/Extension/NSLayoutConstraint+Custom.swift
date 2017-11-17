//
//  NSLayoutConstraint+Custom.swift
//  UserInterface
//
//  Created by Ian McDowell on 11/8/17.
//  Copyright © 2017 Ian McDowell. All rights reserved.
//

import UIKit

public extension NSLayoutConstraint {
    
    func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}
