//
//  ZoomTransition.swift
//  Source
//
//  Created by Ian McDowell on 8/4/16.
//  Copyright © 2016 Ian McDowell. All rights reserved.
//
import UIKit

public class ZoomTransitionController: SOTransitionController {

    private var sourceRect: CGRect

    public init(sourceRect: CGRect?) {

        if let sourceRect = sourceRect {
            self.sourceRect = sourceRect
        } else {
            let bounds = UIScreen.main.bounds

            self.sourceRect = CGRect(x: bounds.width / 2, y: bounds.height / 2, width: 0, height: 0)
        }

        super.init()
    }

    // MARK: UIViewControllerTransitioningDelegate

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ZoomTransition(sourceRect: sourceRect, dismiss: false)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ZoomTransition(sourceRect: sourceRect, dismiss: true)
    }
}

private class ZoomTransition: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning {

    private var sourceRect: CGRect
    private var dismiss: Bool

    init(sourceRect: CGRect, dismiss: Bool) {
        self.sourceRect = sourceRect
        self.dismiss = dismiss
        super.init()
    }

    // MARK: UIViewControllerAnimatedTransitioning

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        guard let fromViewController = transitionContext.viewController(forKey: .from), let toViewController = transitionContext.viewController(forKey: .to) else {
            return
        }
        
        let toView = transitionContext.view(forKey: .to)
        let fromView = transitionContext.view(forKey: .from)
        
        let containerView = transitionContext.containerView

        let isPresenting = !self.dismiss
        
        if let toView = toView {
            if isPresenting {
                containerView.addSubview(toView)
            } else {
                containerView.insertSubview(toView, at: 0)
            }
            
            toView.frame = transitionContext.finalFrame(for: toViewController)
        }

        let fw = (isPresenting ? fromViewController : toViewController).view.frame.width
        let fh = (isPresenting ? fromViewController : toViewController).view.frame.height
        let tx = sourceRect.midX - (fw / 2)
        let ty = sourceRect.midY - (fh / 2)

        // If modal view size is zero, default to 10% of regular size for transform.
        let sx = max(fw == 0 ? 0.1 : sourceRect.size.width / fw, 0.1)
        let sy = max(fh == 0 ? 0.1 : sourceRect.size.height / fh, 0.1)

        // Scale and translate the modal view.
        let transform = CGAffineTransform(a: sx, b: 0, c: 0, d: sy, tx: tx, ty: ty)

        if isPresenting {
            toView?.alpha = 0

            toView?.transform = transform
        } else {
            fromView?.alpha = 1

            fromView?.transform = .identity
        }


        UIView.animate(withDuration:
            self.transitionDuration(using: transitionContext),
            delay: 0,
            usingSpringWithDamping: 300,
            initialSpringVelocity: 5,
            options: .allowUserInteraction,
            animations: {
                if isPresenting {
                    toView?.alpha = 1
                    toView?.transform = .identity
                } else {
                    fromView?.alpha = 0
                    fromView?.transform = transform
                }
            },
            completion: { finished in

                let wasCancelled = transitionContext.transitionWasCancelled
                transitionContext.completeTransition(!wasCancelled)

                if !isPresenting {
                    fromView?.alpha = 1
                    fromView?.transform = .identity
                }
            }
        )
    }
}
