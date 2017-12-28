//
//  TiltedTabViewController.swift
//  TiltedTabView
//
//  Created by Ian McDowell on 12/22/17.
//  Copyright © 2017 Ian McDowell. All rights reserved.
//

import UIKit

public protocol TiltedTabViewControllerDataSource: class {
    func numberOfTabsInTiltedTabViewController() -> Int
    func snapshotForTab(atIndex index: Int) -> UIImage?
    func titleForTab(atIndex index: Int) -> String?
    func indexForActiveTab() -> Int?
}

public protocol TiltedTabViewControllerDelegate: class {
    func tabSelected(atIndex index: Int)
    func tabOpened(atIndex index: Int)
    func tabClosed(atIndex index: Int)
    func tabMoved(fromIndex: Int, toIndex: Int)
}

open class TiltedTabViewController: UICollectionViewController {
    
    public weak var dataSource: TiltedTabViewControllerDataSource?
    public weak var delegate: TiltedTabViewControllerDelegate?
    
    public init() {
        let layout = TiltedTabTiltedCollectionViewLayout()
        super.init(collectionViewLayout: layout)
        layout.delegate = self
        layout.dataSource = self
        
        self.transitioningDelegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    public func reload() {
        self.collectionView?.reloadData()
    }
    public func addTab(atIndex index: Int) {
        delegate?.tabOpened(atIndex: index)
        let indexPath = IndexPath(item: index, section: 0)
        self.collectionView?.insertItems(at: [indexPath])
        self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
    }
    public func removeTab(atIndex index: Int) {
        delegate?.tabClosed(atIndex: index)
        let indexPath = IndexPath(item: index, section: 0)
        self.collectionView?.deleteItems(at: [indexPath])
    }
    
    // MARK: UIViewController
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = UIColor(white: 0.2, alpha: 1)
        
        collectionView?.alwaysBounceVertical = true
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.register(TiltedTabViewCell.self, forCellWithReuseIdentifier: "Tab")
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        switch self.traitCollection.horizontalSizeClass {
        case .compact:
            self.collectionView?.collectionViewLayout = TiltedTabTiltedCollectionViewLayout()
        case .regular:
            self.collectionView?.collectionViewLayout = TiltedTabGridCollectionViewLayout()
        default:
            break
        }
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: UICollectionViewDataSource
extension TiltedTabViewController {
    
    open override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource?.numberOfTabsInTiltedTabViewController() ?? 0
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Tab", for: indexPath) as! TiltedTabViewCell
        
        cell.delegate = self
        cell.title = dataSource?.titleForTab(atIndex: indexPath.item)
        cell.snapshot = dataSource?.snapshotForTab(atIndex: indexPath.item)
        
        return cell
    }
    
    open override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        delegate?.tabMoved(fromIndex: sourceIndexPath.item, toIndex: destinationIndexPath.item)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        delegate?.tabSelected(atIndex: indexPath.item)
    }
}

extension TiltedTabViewController {
    
    open override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let collectionView = scrollView as? UICollectionView, let layout = collectionViewLayout as? TiltedTabTiltedCollectionViewLayout {
            layout.collectionViewDidScroll(collectionView)
        }
    }
    

}

extension TiltedTabViewController: TiltedTabViewCellDelegate {
    func tiltedTabViewCellCloseButtonTapped(_ cell: TiltedTabViewCell) {
        guard let indexPath = collectionView?.indexPath(for: cell) else {
            return
        }
        self.removeTab(atIndex: indexPath.item)
    }
}

extension TiltedTabViewController: UIViewControllerTransitioningDelegate {
    
    private class PresentingAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
        
        let tabViewController: TiltedTabViewController?
        let activatedTabIndex: Int?
        
        init(tabViewController: TiltedTabViewController?, activatedTabIndex: Int?) {
            self.tabViewController = tabViewController; self.activatedTabIndex = activatedTabIndex
        }
        
        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return 0.5
        }
        
        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
            guard let fromViewController = transitionContext.viewController(forKey: .from), let toViewController = transitionContext.viewController(forKey: .to) else {
                return
            }
            
            let toView = transitionContext.view(forKey: .to)
            let fromView = transitionContext.view(forKey: .from)
            let fromSnapshot = fromView?.snapshotView(afterScreenUpdates: true)
            
            let containerView = transitionContext.containerView
            
            if let toView = toView, let fromView = fromView, let fromSnapshot = fromSnapshot {
                containerView.insertSubview(fromSnapshot, aboveSubview: fromView)
                containerView.insertSubview(toView, belowSubview: fromSnapshot)
                toView.frame = transitionContext.finalFrame(for: toViewController)
            }
            
            let finalPosition: CGRect
            let finalTransform: CATransform3D
            if
                let tabViewController = tabViewController,
                let activatedTabIndex = activatedTabIndex,
                let layout = tabViewController.collectionViewLayout as? TiltedTabCollectionViewLayout
            {
                layout.prepare()
                let attributes = layout.layoutAttributesForItem(at: IndexPath(item: activatedTabIndex, section: 0))!
                
                finalPosition = attributes.frame
                finalTransform = attributes.transform3D
            } else {
                // Fall back to a scale transform
                finalTransform = CATransform3DMakeScale(0.5, 0.5, 1)
                finalPosition = fromView?.frame ?? .zero
            }
            
            toView?.alpha = 0
            UIView.animate(withDuration:
                self.transitionDuration(using: transitionContext),
                delay: 0,
                usingSpringWithDamping: 300,
                initialSpringVelocity: 5,
                options: .allowUserInteraction,
                animations: {
                    toView?.alpha = 1
                    
                    fromSnapshot?.layer.transform = finalTransform
                    fromSnapshot?.frame = finalPosition
                    fromSnapshot?.alpha = 0
                },
                completion: { finished in
                            
                    let wasCancelled = transitionContext.transitionWasCancelled
                    transitionContext.completeTransition(!wasCancelled)
                    
                    fromSnapshot?.removeFromSuperview()
                }
            )
        }
    }
    
    private class DismissingAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
        
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
            
            if let toView = toView {
                containerView.addSubview(toView)
                toView.frame = transitionContext.finalFrame(for: toViewController)
            }
            
            toView?.alpha = 0
            toView?.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            UIView.animate(withDuration:
                self.transitionDuration(using: transitionContext),
                delay: 0,
                usingSpringWithDamping: 300,
                initialSpringVelocity: 5,
                options: .allowUserInteraction,
                animations: {
                    fromView?.alpha = 0
                    toView?.alpha = 1
                    toView?.transform = .identity
                },
                completion: { finished in
                            
                    let wasCancelled = transitionContext.transitionWasCancelled
                    transitionContext.completeTransition(!wasCancelled)
                }
            )
        }
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentingAnimationController(
            tabViewController: presented as? TiltedTabViewController ?? (presented as? UINavigationController)?.childViewControllers.first as? TiltedTabViewController,
            activatedTabIndex: (source as? TiltedTabViewControllerDataSource)?.indexForActiveTab()
        )
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissingAnimationController()
    }
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return nil
    }
}
