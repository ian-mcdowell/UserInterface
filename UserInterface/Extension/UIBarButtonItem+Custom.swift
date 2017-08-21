//
//  UIBarButtonItem+Custom.swift
//  Source
//
//  Created by Ian McDowell on 12/22/16.
//  Copyright © 2016 Ian McDowell. All rights reserved.
//

public extension UIBarButtonItem {
    
    /// PRIVATE: Accessing the view of a UIBarButtonItem requires privately looking at it's "view" property.
    public var privateView: UIView? {
        
        if let view = self.perform(NSSelectorFromString("view")).takeUnretainedValue() as? UIView {
            return view
        }
        return nil
    }

    /// PRIVATE: Accessing the view of a UIBarButtonItem requires privately looking at it's "view" property.
    public var frame: CGRect? {

        return self.privateView?.frame
    }

    /// PRIVATE: Accessing the view of a UIBarButtonItem requires privately looking at it's "view" property.
    public func frame(relativeTo enclosingView: UIView?) -> CGRect? {
        
        if let view = self.privateView {
            return view.superview?.convert(view.frame, to: enclosingView)
        }
        return nil
    }
}
