//
//  UIViewController+CheckDeallocation.swift
//  UserInterface
//
//  Created by Ian McDowell on 7/6/17.
//  Copyright © 2017 Ian McDowell. All rights reserved.
//

import UIKit

#if DEBUG
public extension UIViewController {
    
    /// This method asserts whether a view controller gets deallocated after it disappeared
    /// due to one of these reasons:
    /// - it was removed from its parent, or
    /// - it (or one of its parents) was dismissed.
    ///
    /// **You should call this method only from UIViewController.viewDidDisappear(_:).**
    /// - Parameter delay: Delay after which the check if a
    ///                    view controller got deallocated is performed
    public func checkDeallocation(afterDelay delay: TimeInterval = 2.0) {
        
        guard let rootParentViewController = self.rootParentViewController else {
            return
        }
        
        // We don't check `isBeingDismissed` simply on this view controller because it's common
        // to wrap a view controller in another view controller (e.g. a stock UINavigationController)
        // and present the wrapping view controller instead.
        if isMovingFromParentViewController || rootParentViewController.isBeingDismissed {
            let type = Swift.type(of: self)
            let disappearanceSource: String = isMovingFromParentViewController ? "removed from its parent" : "dismissed as part of \(rootParentViewController)"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: { [weak self] in
                if self != nil {
                    print("\(type) not deallocated after being \(disappearanceSource)")
                }
            })
        }
    }
    
    private var rootParentViewController: UIViewController? {
        var root = self
        
        if let dcv = root as? DeallocationCheckedViewController, !dcv.shouldBeDeallocatedAfterDismissal {
            return nil
        }
        
        while let parent = root.parent {
            root = parent
            
            if let dcv = root as? DeallocationCheckedViewController, !dcv.shouldBeDeallocatedAfterDismissal {
                return nil
            }
        }
        
        return root
    }
}

public protocol DeallocationCheckedViewController: class {
    
    var shouldBeDeallocatedAfterDismissal: Bool { get }
}

public extension DeallocationCheckedViewController {
    public var shouldBeDeallocatedAfterDismissal: Bool { return true }
}
#endif
