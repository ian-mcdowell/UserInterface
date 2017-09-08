//
//  SOTabViewController.swift
//  UserInterface
//
//  Created by Ian McDowell on 2/3/17.
//  Copyright © 2017 Ian McDowell. All rights reserved.
//

import Foundation

private class SOResizableCollectionView: UICollectionView {
    
    override var frame: CGRect {
        didSet {
            self.collectionViewLayout.invalidateLayout()
        }
    }

}

open class SOTabViewController: SOViewController, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    private var tabView: UICollectionView
    private var layout: UICollectionViewFlowLayout
    
    private var tabContainer: SOTabNavigationController
    
    public var viewControllers = [UIViewController]()
    public var visibleViewController: UIViewController?
    
    // MARK: Init
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        layout = SOCollectionViewFlowLayout()
        tabView = SOResizableCollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        
        tabContainer = SOTabNavigationController()
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = []
        
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets.zero
        
        // Tab view
        tabView.backgroundColor = nil
        tabView.showsHorizontalScrollIndicator = false
        tabView.showsVerticalScrollIndicator = false
        tabView.alwaysBounceHorizontal = true
        
        tabView.dataSource = self
        tabView.delegate = self
        
        tabView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(SOTabViewController.handleLongPressGesture(gesture:))))
        
        tabView.register(SOTabViewTab.self)
        
        tabView.frame = self.navigationController!.navigationBar.bounds
        tabView.autoresizingMask = .flexibleWidth
        navigationItem.titleView = tabView
        
        // Tab container
        tabContainer.delegate = self
        
        tabContainer.isNavigationBarHidden = true
        tabContainer.isToolbarHidden = true
        tabContainer.view.backgroundColor = nil
        
        addChildViewController(tabContainer)
        view.addSubview(tabContainer.view)
        
        tabContainer.view.constrainToEdgesOfSuperview()
        
        tabContainer.didMove(toParentViewController: self)
    }
    
    override open func applyTheme(_ theme: Theme) {
        super.applyTheme(theme)
        
        self.view.backgroundColor = theme.backgroundColor
    }
    
    /// Activates the given tab and saves the new state
    ///
    /// - Parameters:
    ///   - viewController: the tab to activate
    ///   - saveState: if the new state should be saved
    open func activateTab(_ tab: UIViewController) {
        
        tabContainer.pushViewController(tab, animated: false)
    }
    
    /// Closes the provided tab and selects another tab to be active.
    ///
    /// - Parameter tab: the tab to close
    open func closeTab(_ tab: UIViewController) {
        tabContainer.removeViewController(tab, animated: false)
        
        if let index = viewControllers.index(of: tab) {
            viewControllers.remove(at: index)
            tabView.reloadData()
        }
        if viewControllers.isEmpty {
            tabContainer.viewControllers = []
        }
        
        selectActiveTab()
        self.visibleViewController = nil
    }
    
    // MARK: UINavigationControllerDelegate
    public func navigationController(_ navigationController: UIKit.UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        // sync tab view controllers with nav view controllers
        // TODO: make this faster
        
        tabView.performBatchUpdates({
            
            for vc in navigationController.viewControllers {
                
                if !self.viewControllers.contains(vc) {
                    self.viewControllers.append(vc)
                    self.tabView.insertItems(at: [IndexPath(row: self.viewControllers.count - 1, section: 0)])
                }
            }
            
            for vc in self.viewControllers {
                if !navigationController.viewControllers.contains(vc) {
                    if let index = self.viewControllers.index(of: vc) {
                        self.viewControllers.remove(at: index)
                        self.tabView.deleteItems(at: [IndexPath(row: index, section: 0)])
                    }
                    
                }
            }
            
        }, completion: nil)
    }
    
    public func navigationController(_ navigationController: UIKit.UINavigationController, didShow viewController: UIViewController, animated: Bool) {

        self.visibleViewController = viewController
        selectActiveTab()
    }
    
    func selectActiveTab() {
        
        if let tab = tabContainer.visibleViewController {
            
            if let index = viewControllers.index(of: tab) {
                
                let indexPath = IndexPath(item: index, section: 0)
                tabView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
            }
        } else {
            if let rows = tabView.indexPathsForSelectedItems {
                for row in rows {
                    tabView.deselectItem(at: row, animated: true)
                }
            }
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewControllers.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(SOTabViewTab.self, for: indexPath)
        
        cell.tabViewController = self
        
        cell.setTab(viewControllers[indexPath.row])
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewController = viewControllers[indexPath.row]
        
        self.activateTab(viewController)
    }
    
    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Allow for reordering tabs
        
        // Swap in the editors array
        swap(&viewControllers[sourceIndexPath.row], &viewControllers[destinationIndexPath.row])
        
        // Swap in the navigation controller
        tabContainer.swapViewControllers(fromIndex: sourceIndexPath.row, toIndex: destinationIndexPath.row, animated: false)
        
        if let vc = visibleViewController {
            self.activateTab(vc)
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cvHeight = collectionView.frame.size.height
        let cvWidth = collectionView.frame.size.width
        
        let numVCs = CGFloat(viewControllers.count)
        
        return CGSize(width: max(150, cvWidth / numVCs), height: cvHeight)
    }
    
    // MARK: Long press gesture
    
    @objc func handleLongPressGesture(gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
            
        case .began:
            guard let selectedIndexPath = self.tabView.indexPathForItem(at: gesture.location(in: self.tabView)) else {
                break
            }
            self.tabView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            self.tabView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            self.tabView.endInteractiveMovement()
        default:
            self.tabView.cancelInteractiveMovement()
        }
    }

}


// Custom navigation controller that reorders views instead of pushing duplicates.
private class SOTabNavigationController: SONavigationController {
    
    fileprivate override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func moveToTopOfNavigationStack(viewControllerAtIndex index: Int, animated: Bool) {
        var stack = viewControllers
        if index == stack.count - 1 {
            // nothing to do because it's already on top
            return
        }
        let vc = stack.remove(at: index)
        setViewControllers(stack, animated: false)
        stack.append(vc)
        setViewControllers(stack, animated: animated)
    }
    
    fileprivate func swapViewControllers(fromIndex: Int, toIndex: Int, animated: Bool) {
        var stack = viewControllers
        
        stack.swapAt(fromIndex, toIndex)
        setViewControllers(stack, animated: animated)
    }
    
    // Override for pushViewController so existing controllers will be brought back to the top instead of duplicated.
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        if let index = viewControllers.index(where: { $0 == viewController }) {
            moveToTopOfNavigationStack(viewControllerAtIndex: index, animated: animated)
        } else {
            super.pushViewController(viewController, animated: animated)
        }
    }
    
    func removeViewController(_ viewController: UIViewController, animated: Bool) {
        
        if let index = viewControllers.index(where: { $0 == viewController }) {
            moveToTopOfNavigationStack(viewControllerAtIndex: index, animated: animated)
            popViewController(animated: animated)
        }
    }
}


private class SOTabViewTab: SOCollectionViewCell {
    
    private var titleView: UILabel
    private var closeButton: UIButton
    
    private var bottomBorder: UIView!
    
    private var currentTab: UIViewController?
    weak var tabViewController: SOTabViewController?
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                bottomBorder.backgroundColor = Theme.current.borderSelectedColor
            } else {
                bottomBorder.backgroundColor = Theme.current.borderColor
            }
        }
    }
    
    override init(frame: CGRect) {
        titleView = UILabel()
        closeButton = UIButton()
        bottomBorder = UIView()
        
        super.init(frame: frame)

        let closeImg = UIImage(named: "Close", in: Bundle(for: SOTabViewController.self), compatibleWith: self.traitCollection)
        closeButton.setImage(closeImg?.scaled(toSize: CGSize(width: 20, height: 20)), for: UIControlState())
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
        closeButton.setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
        
        closeButton.addTarget(self, action: #selector(SOTabViewTab.closeButtonTapped), for: .touchUpInside)
        
        contentView.addSubview(closeButton)
        
        closeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        closeButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        titleView.textAlignment = .left
        titleView.translatesAutoresizingMaskIntoConstraints = false
        titleView.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.regular)
        contentView.addSubview(titleView)
        titleView.leadingAnchor.constraint(equalTo: closeButton.trailingAnchor, constant: 10).isActive = true
        titleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        titleView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        titleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        bottomBorder.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(bottomBorder)
        bottomBorder.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 1).isActive = true
        bottomBorder.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -1).isActive = true
        bottomBorder.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        bottomBorder.heightAnchor.constraint(equalToConstant: 3).isActive = true
        
        self.isSelected = false
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func applyTheme(_ theme: Theme) {
        super.applyTheme(theme)
        
        titleView.textColor = theme.tableCellTextColor
    }
    
    func setTab(_ tab: UIViewController) {
        currentTab = tab
        
        titleView.text = tab.title
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleView.text = nil
    }
    
    @objc func closeButtonTapped() {
        if let currentTab = currentTab {
            tabViewController?.closeTab(currentTab)
        }
    }
}
