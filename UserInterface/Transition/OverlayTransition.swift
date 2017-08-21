//
//  OverlayTransition.swift
//  UserInterface
//
//  Created by Ian McDowell on 2/17/17.
//  Copyright © 2017 Ian McDowell. All rights reserved.
//

import Foundation

public class OverlayTransitionController: SOTransitionController {
    
    // MARK: UIViewControllerTransitioningDelegate
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        return OverlayPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return OverlayTransition(dismiss: false)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return OverlayTransition(dismiss: true)
    }
    
}

private class OverlayTransition: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning {

    private let isPresentation: Bool
    
    init(dismiss: Bool) {
        isPresentation = !dismiss
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
        dismissedFrame.origin.y = containerView.frame.height
        
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
    
    private let dimmingView: UIView
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        
        dimmingView = UIView()
        dimmingView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        dimmingView.alpha = 0
        
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dimmingViewTapped))
        dimmingView.addGestureRecognizer(tap)
    }
    
    func dimmingViewTapped() {
        self.presentingViewController.dismiss(animated: true, completion: nil)
    }
    
    override func presentationTransitionWillBegin() {
        // Set up for the presentation
        
        guard let containerView = self.containerView else {
            return
        }
        
        presentedView?.layer.cornerRadius = 10
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
        
        let topOffset: CGFloat = 75
        
        let maxWidth: CGFloat = 500
        let maxHeight: CGFloat = 800
        
        // Try to fulfill preferred content size.
        if container.preferredContentSize != .zero {
            return CGSize(width: min(container.preferredContentSize.width, parentSize.width), height: min(container.preferredContentSize.height, parentSize.height - topOffset))
        }
        
        return CGSize(width: min(parentSize.width, maxWidth), height: min(parentSize.height - topOffset, maxHeight))
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
        
        
        if containerBounds.size.width > presentedViewFrame.size.width {
            // Center on screen if width is smaller than the container view
            presentedViewFrame.origin.x = (containerBounds.size.width - presentedViewFrame.size.width) / 2
            presentedViewFrame.origin.y = (containerBounds.size.height - presentedViewFrame.size.height) / 2
        } else {
            // Show from bottom of screen
            presentedViewFrame.origin.y = containerBounds.size.height - presentedViewFrame.size.height
        }
        
        return presentedViewFrame
    }
}
