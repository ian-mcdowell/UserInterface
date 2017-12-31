//
//  UIView+Custom.swift
//  Source
//
//  Created by Ian McDowell on 8/20/16.
//  Copyright © 2016 Ian McDowell. All rights reserved.
//

import UIKit

public extension UIView {

    /// Add leading, trailing, top, and bottom constraints based off the given UIEdgeInsets
    ///
    /// - Parameter edgeInsets: optional UIEdgeInsets to use as the constants for the constraints
    public func constrainToEdgesOfSuperview(_ edgeInsets: UIEdgeInsets = UIEdgeInsets.zero) {
        self.translatesAutoresizingMaskIntoConstraints = false

        self.leadingAnchor.constraint(equalTo: (self.superview?.leadingAnchor)!, constant: edgeInsets.left).isActive = true
        self.trailingAnchor.constraint(equalTo: (self.superview?.trailingAnchor)!, constant: -edgeInsets.right).isActive = true
        self.topAnchor.constraint(equalTo: (self.superview?.topAnchor)!, constant: edgeInsets.top).isActive = true
        self.bottomAnchor.constraint(equalTo: (self.superview?.bottomAnchor)!, constant: -edgeInsets.bottom).isActive = true
    }

    /// Recursive method to find the current first responder if it is inside the view.
    ///
    /// - Returns: A UIView which is currently the first responder. If no views are the virst responder, returns nil.
    public func findFirstResponder() -> UIView? {
        if self.isFirstResponder {
            return self
        }
        for view in self.subviews {
            if let responder = view.findFirstResponder() {
                return responder
            }
        }
        return nil
    }

    /// Loads the contents of a nib with the same name as the current class into the view.
    ///
    /// - Returns: the view that was loaded
    @discardableResult
    public func fromNib<T: UIView>() -> T? {
        guard let view = Bundle.main.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?[0] as? T else {
            fatalError("Nib was not loaded or the root view of the nib is the incorrect type.")
        }
        self.addSubview(view)
        view.constrainToEdgesOfSuperview()
        return view
    }
}
