//
//  UIViewController+Empty.swift
//  UserInterface
//
//  Created by Ian McDowell on 2/18/17.
//  Copyright © 2017 Ian McDowell. All rights reserved.
//
import UIKit

/// Since extensions can not officially have stored properties,
/// we use the objc_runtime to set and get associated objects.
/// This is the key used for storage and retrieval.
private var emptyLabelAssociatedObjectKey: UInt8 = 0

public extension UIView {
    
    public var emptyLabel: EmptyLabel {
        if let emptyLabel = objc_getAssociatedObject(self, &emptyLabelAssociatedObjectKey) as? EmptyLabel {
            return emptyLabel
        } else {
            let emptyLabel = EmptyLabel(self)
            objc_setAssociatedObject(self, &emptyLabelAssociatedObjectKey, emptyLabel, .OBJC_ASSOCIATION_RETAIN)
            return emptyLabel
        }
    }
}

public class EmptyLabel {
    
    private var view: UIView
    
    private var label: UILabel? = nil
    
    fileprivate init(_ view: UIView) {
        self.view = view
    }
    
    deinit {
        // Make sure we don't leave the label behind when we get deallocated.
        label?.removeFromSuperview()
    }
    
    public var text: String = "" {
        didSet {
            self.label?.text = text
        }
    }
    
    public var textColor: UIColor = .black {
        didSet {
            self.label?.textColor = textColor
        }
    }
    
    public var isHidden: Bool {
        get {
            return self.label != nil && self.label!.superview != nil
        }
        set {
            if newValue {
                remove()
            } else {
                show()
            }
        }
    }
    
    /// Construct a new empty view, and add it to the view controller's view.
    public func show() {
        
        // Make sure there isn't already a progress view. If there is, this will remove it.
        self.label?.removeFromSuperview()
        
        // Create the new view and add it to the view controller.
        self.label = {
            let p = UILabel()
            
            p.translatesAutoresizingMaskIntoConstraints = false
            p.baselineAdjustment = .alignCenters
            p.textAlignment = .center
            p.numberOfLines = 0
            p.font = UIFont.preferredFont(forTextStyle: .title2)
            p.adjustsFontSizeToFitWidth = true
            p.text = self.text
            p.textColor = self.textColor
            
            self.view.addSubview(p)
            
            p.constrainToEdgesOfSuperview(UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 20))
            
            return p
        }()
    }
    
    public func remove() {
        // Remove the view from the screen
        self.label?.removeFromSuperview()
        self.label = nil
    }
}
