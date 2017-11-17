//
//  DraggableSplitViewController.swift
//  UserInterface
//
//  Created by Ian McDowell on 11/1/17.
//  Copyright © 2017 Ian McDowell. All rights reserved.
//

import UIKit

public class DraggableSplitViewController: SOViewController {
    
    public enum Direction {
        case vertical
        case horizontal
        
        fileprivate var draggerImage: UIImage {
            switch self {
            case .horizontal:
                return UIImage.init(named: "Dragger_Vertical", in: Bundle.init(for: DraggableSplitViewController.self), compatibleWith: nil)!
            case .vertical:
                return UIImage.init(named: "Dragger_Horizontal", in: Bundle.init(for: DraggableSplitViewController.self), compatibleWith: nil)!
            }
        }
        
        fileprivate var stackViewAxis: UILayoutConstraintAxis {
            switch self {
            case .horizontal:
                return .horizontal
            case .vertical:
                return .vertical
            }
        }
        
        fileprivate func draggerViewSizeConstraint(_ draggerView: UIView) -> NSLayoutConstraint {
            switch self {
            case .horizontal:
                return draggerView.widthAnchor.constraint(lessThanOrEqualToConstant: 22)
            case .vertical:
                return draggerView.heightAnchor.constraint(lessThanOrEqualToConstant: 22)
            }
        }
    }
    
    public var maxSplitPercentage: CGFloat = 1
    public var minSplitPercentage: CGFloat = 0
    public var splitPercentage: CGFloat = 0.5 {
        didSet {
            self.view.setNeedsLayout()
        }
    }
    public var direction: Direction {
        didSet {
            splitPercentage = 0.5
            self.updateLayout()
        }
    }
    public var leadingViewController: UIViewController? {
        didSet {
            oldValue?.removeFromParent()
            if let leadingViewController = leadingViewController {
                addChildViewController(leadingViewController)
            }
            self.updateLayout()
        }
    }
    public var trailingViewController: UIViewController? {
        didSet {
            oldValue?.removeFromParent()
            if let trailingViewController = trailingViewController {
                addChildViewController(trailingViewController)
            }
            self.updateLayout()
        }
    }
    
    private var draggerView: DraggerView?
    private var stackView: UIStackView?
    private var draggerViewPositionConstraint: NSLayoutConstraint? {
        didSet {
            draggerViewPositionConstraint?.isActive = true
        }
    }
    
    // MARK: Init
    
    public init(direction: Direction, leadingViewController: UIViewController?, trailingViewController: UIViewController?) {
        self.direction = direction
        self.leadingViewController = leadingViewController
        self.trailingViewController = trailingViewController

        super.init(nibName: nil, bundle: nil)
        
        if let leadingViewController = leadingViewController {
            addChildViewController(leadingViewController)
        }
        if let trailingViewController = trailingViewController {
            addChildViewController(trailingViewController)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: ViewController lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLayout()
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        var totalSize: CGFloat
        switch direction {
        case .horizontal:
            totalSize = view.frame.size.width
        case .vertical:
            totalSize = view.frame.size.height
        }
        totalSize -= draggerView?.sizeConstraint?.constant ?? 0
        draggerViewPositionConstraint?.constant = totalSize * splitPercentage
    }
    
    public override func applyTheme(_ theme: Theme) {
        super.applyTheme(theme)
        
        draggerView?.applyTheme(theme)
    }
    
    /// Update the dragger view's position and visibility
    /// Called when leading/trailing view controller changes
    private func updateLayout() {
        for view in view.subviews {
            view.removeFromSuperview()
        }
        
        if let leadingViewController = leadingViewController, let trailingViewController = trailingViewController {
            // Create a stack view and set it as root
            let draggerView = DraggerView(direction: direction)
            draggerView.splitViewController = self
            
            let stackView = UIStackView(
                arrangedSubviews: [leadingViewController.view, draggerView, trailingViewController.view]
            )
            switch self.direction {
            case .horizontal:
                self.draggerViewPositionConstraint = draggerView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor)
            case .vertical:
                self.draggerViewPositionConstraint = draggerView.topAnchor.constraint(equalTo: stackView.topAnchor)
            }
            stackView.axis = direction.stackViewAxis
            
            self.stackView = stackView
            self.draggerView = draggerView
            
            view.addSubview(stackView)
            stackView.constrainToEdgesOfSuperview()
        } else {
            // Hide stack view
            self.stackView = nil
            self.draggerView = nil
            
            if let leadingViewController = leadingViewController {
                view.addSubview(leadingViewController.view)
                leadingViewController.view.constrainToEdgesOfSuperview()
                leadingViewController.didMove(toParentViewController: self)
            } else if let trailingViewController = trailingViewController {
                view.addSubview(trailingViewController.view)
                trailingViewController.view.constrainToEdgesOfSuperview()
                trailingViewController.didMove(toParentViewController: self)
            }
        }
    }
    
    private class DraggerView: UIView, Themeable {
        
        weak var splitViewController: DraggableSplitViewController?
        
        let direction: Direction
        
        var sizeConstraint: NSLayoutConstraint? {
            didSet {
                sizeConstraint?.isActive = true
            }
        }
        
        private let imageView: UIImageView
        
        init(direction: Direction) {
            self.direction = direction
            self.imageView = UIImageView.init(image: direction.draggerImage)
            super.init(frame: .zero)
            self.sizeConstraint = direction.draggerViewSizeConstraint(self)
            self.sizeConstraint?.isActive = true
            
            imageView.contentMode = .center
            addSubview(imageView)
            imageView.constrainToEdgesOfSuperview()
            
            isUserInteractionEnabled = true
            addGestureRecognizer(
                UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
            )
        }
        
        required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
        
        func applyTheme(_ theme: Theme) {
            backgroundColor = theme.backgroundColor
        }
        
        @objc private func didPan(_ panGesture: UIPanGestureRecognizer) {
            guard let splitViewController = splitViewController else { return }
            
            let location = panGesture.location(in: splitViewController.view)
            let percent: CGFloat
            switch direction {
            case .horizontal:
                percent = location.x / (splitViewController.view.frame.size.width - self.frame.size.width)
            case .vertical:
                percent = location.y / (splitViewController.view.frame.size.height - self.frame.size.height)
            }
            
            splitViewController.splitPercentage = min(splitViewController.maxSplitPercentage, max(splitViewController.minSplitPercentage, percent))
        }
    }
}
