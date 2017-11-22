//
//  SONavigationController.swift
//  Source
//
//  Created by Ian McDowell on 8/20/16.
//  Copyright © 2016 Ian McDowell. All rights reserved.
//
import UIKit

/// UINavigationController that looks at its top view controller to determine orientation and rotation
open class SONavigationController: UINavigationController {

    public var transitionController: SOTransitionController? {
        didSet {
            self.modalPresentationStyle = .custom
            self.transitioningDelegate = transitionController
        }
    }

    open override var shouldAutorotate: Bool {
        return topViewController?.shouldAutorotate ?? true
    }

    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return topViewController?.supportedInterfaceOrientations ?? UIInterfaceOrientationMask.all
    }

    open override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return topViewController?.preferredInterfaceOrientationForPresentation ?? UIInterfaceOrientation.portrait
    }
    
}
