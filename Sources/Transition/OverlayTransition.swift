//
//  OverlayTransition.swift
//  UserInterface
//
//  Created by Ian McDowell on 2/17/17.
//  Copyright © 2017 Ian McDowell. All rights reserved.
//
import UIKit

public enum OverlayTransitionDirection {
    case fromBottom
    case fromLeft
}

public class OverlayTransitionController: SOTransitionController {
    
    let direction: OverlayTransitionDirection
    public init(direction: OverlayTransitionDirection = .fromBottom) {
        self.direction = direction
    }
    
    // MARK: UIViewControllerTransitioningDelegate
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        return OverlayPresentationController(direction: direction, presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return OverlayTransition(direction: direction, dismiss: false)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return OverlayTransition(direction: direction, dismiss: true)
    }
    
}

private class OverlayTransition: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning {

    private let isPresentation: Bool
    private let direction: OverlayTransitionDirection
    
    init(direction: OverlayTransitionDirection, dismiss: Bool) {
        self.direction = direction
        self.isPresentation = !dismiss
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromVC = transitionContext.viewController(forKey: .from), let toVC = transitionContext.viewController(forKey: .to) else {
            return
        }
        guard let fromView = fromVC.view, let toView = toVC.view else {
            return
        }
        
        let containerView = transitionContext.containerView
        
        if isPresentation {
            containerView.addSubview(toView)
        }
        
        let animatingVC = isPresentation ? toVC : fromVC
        let animatingView = isPresentation ? toView : fromView
        
        let appearedFrame = transitionContext.finalFrame(for: animatingVC)
        
        var dismissedFrame = appearedFrame
        switch direction {
        case .fromBottom:
            dismissedFrame.origin.y = containerView.frame.height
        case .fromLeft:
            dismissedFrame.origin.x = -containerView.frame.width
        }
        
        let initialFrame = isPresentation ? dismissedFrame : appearedFrame
        let finalFrame = isPresentation ? appearedFrame : dismissedFrame
        
        animatingView.frame = initialFrame
        
        UIView.animate(withDuration:
            self.transitionDuration(using: transitionContext),
            delay: 0,
            usingSpringWithDamping: 300,
            initialSpringVelocity: 5,
            options: [.allowUserInteraction, .beginFromCurrentState],
            animations: {
                animatingView.frame = finalFrame
            },
            completion: { finished in
                
                if !self.isPresentation {
                    fromView.removeFromSuperview()
                }
                
                transitionContext.completeTransition(true)
            }
        )
    }
}

private class OverlayPresentationController: UIPresentationController {
    
    private let direction: OverlayTransitionDirection
    private let dimmingView: UIView
    
    init(direction: OverlayTransitionDirection, presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        
        self.direction = direction
        
        dimmingView = UIView()
        dimmingView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        dimmingView.alpha = 0
        
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dimmingViewTapped))
        dimmingView.addGestureRecognizer(tap)
    }
    
    @objc func dimmingViewTapped() {
        self.presentingViewController.dismiss(animated: true, completion: nil)
    }
    
    override func presentationTransitionWillBegin() {
        // Set up for the presentation
        
        guard let containerView = self.containerView else {
            return
        }
        
        presentedView?.layer.cornerRadius = 10
        switch direction {
        case .fromBottom:
            presentedView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case .fromLeft:
            presentedView?.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        }
        
        presentedView?.layer.masksToBounds = true
        
        // Make sure the dimming view is the size of the container's bounds and fully transparent
        
        dimmingView.frame = containerView.bounds
        dimmingView.alpha = 0
        
        // Insert the dimming view below everything else
        
        containerView.insertSubview(dimmingView, at: 0)
        
        if let transitionCoordinator = presentedViewController.transitionCoordinator {
            
            transitionCoordinator.animate(alongsideTransition: { context in
                
                // Fade the dimming view to be fully visible
                self.dimmingView.alpha = 1
            }, completion: nil)
        } else {
            
            self.dimmingView.alpha = 1
            
        }
    }
    
    override func dismissalTransitionWillBegin() {
        
        // Undo what we did in presentationTransitionWillBegin. Fade the dimming view to be fully transparent
        
        if let transitionCoordinator = presentedViewController.transitionCoordinator {
            transitionCoordinator.animate(alongsideTransition: { context in
                
                self.dimmingView.alpha = 0
                
            }, completion: nil)
        } else {
            
            self.dimmingView.alpha = 0
            
        }
    }
    
    override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        UIView.animateKeyframes(withDuration: 0, delay: 0, options: .beginFromCurrentState, animations: {
            self.presentedView?.frame = self.frameOfPresentedViewInContainerView
        }, completion: nil)
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        
        presentedView?.layer.cornerRadius = 0
    }
    
    override var adaptivePresentationStyle: UIModalPresentationStyle {
        return .overFullScreen
    }
    
    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        
        var topOffset: CGFloat = 0
        var bottomOffset: CGFloat = 0
        var rightOffset: CGFloat = 0
        var leftOffset: CGFloat = 0
        
        switch direction {
        case .fromBottom:
            topOffset = 75
        case .fromLeft:
            rightOffset = 83 // iphone x notch from right
        }
        
        let width = parentSize.width - rightOffset - leftOffset
        let height = parentSize.height - topOffset - bottomOffset
        
        // Try to fulfill preferred content size.
        if container.preferredContentSize != .zero {
            return CGSize(
                width: min(container.preferredContentSize.width, height),
                height: min(container.preferredContentSize.height, height)
            )
        }
        
        return CGSize(width: width, height: height)
    }
    
    override func containerViewWillLayoutSubviews() {
        
        dimmingView.frame = containerView?.bounds ?? .zero
        presentedView?.frame = self.frameOfPresentedViewInContainerView
    }
    
    override var shouldPresentInFullscreen: Bool {
        // This is a full screen presentation
        return true
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        
        // Return a rect with the same size as size(forChildContentContainer... ), but on bottom of screen.
        
        var presentedViewFrame = CGRect.zero
        let containerBounds = self.containerView?.bounds ?? .zero
        
        presentedViewFrame.size = self.size(forChildContentContainer: presentedViewController, withParentContainerSize: containerBounds.size)
        
        switch direction {
        case .fromBottom:
            // Show from bottom of screen
            presentedViewFrame.origin.y = containerBounds.size.height - presentedViewFrame.size.height
            presentedViewFrame.origin.x = (containerBounds.size.width - presentedViewFrame.size.width) / 2
        case .fromLeft:
            // Show from left of screen
            presentedViewFrame.origin.x = 0
            presentedViewFrame.origin.y = (containerBounds.size.height - presentedViewFrame.size.height) / 2
        }
        
        return presentedViewFrame
    }
}
