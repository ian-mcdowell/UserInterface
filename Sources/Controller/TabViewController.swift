//
//  TabViewController.swift
//  UserInterface
//
//  Created by Ian McDowell on 2/3/17.
//  Copyright © 2017 Ian McDowell. All rights reserved.
//
import UIKit

private let barHeight: CGFloat = 44
private let tabHeight: CGFloat = 32

open class TabViewController: SOViewController {
    
    private let tabViewBar: TabViewBar
    private let contentView: UIView
    
    private let model: TabViewControllerModel
    
    /// The current tab shown in the tab view controller's content view
    public var visibleViewController: UIViewController? {
        return model.visibleViewController
    }
    /// All of the tabs, in order.
    public var viewControllers: [UIViewController] {
        return model.viewControllers
    }
    
    public var leftBarButtonItems: [UIBarButtonItem] = [] {
        didSet {
            refreshTabBar()
        }
    }
    public var rightBarButtonItems: [UIBarButtonItem] = [] {
        didSet {
            refreshTabBar()
        }
    }
    
    public var emptyView: UIView? = nil {
        didSet {
            oldValue?.removeFromSuperview()
            refreshEmptyView()
        }
    }
    
    // MARK: Init
    
    public init() {
        tabViewBar = TabViewBar()
        contentView = UIView()
        model = TabViewControllerModel()
        
        super.init(nibName: nil, bundle: nil)
        
        model.tabViewController = self
        
        tabViewBar.barDataSource = model
        tabViewBar.barDelegate = model
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        tabViewBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tabViewBar)
        NSLayoutConstraint.activate([
            tabViewBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabViewBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabViewBar.topAnchor.constraint(equalTo: view.topAnchor)
        ])
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: tabViewBar.bottomAnchor),
            contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = nil
    }

    override open func applyTheme(_ theme: Theme) {
        super.applyTheme(theme)

        self.view.backgroundColor = theme.backgroundColor
        tabViewBar.applyTheme(theme)
    }
    
    /// Activates the given tab and saves the new state
    ///
    /// - Parameters:
    ///   - viewController: the tab to activate
    ///   - saveState: if the new state should be saved
    open func activateTab(_ tab: UIViewController) {
        model.activateTab(tab)
    }
    
    /// Closes the provided tab and selects another tab to be active.
    ///
    /// - Parameter tab: the tab to close
    open func closeTab(_ tab: UIViewController) {
        model.closeTab(tab)
    }
    
    // MARK: Model methods
    
    fileprivate var currentContentViewController: UIViewController? {
        didSet {
            oldValue?.removeFromParentViewController()
            oldValue?.view.removeFromSuperview()
            
            if let contentViewController = currentContentViewController {
                addChildViewController(contentViewController)
                contentView.addSubview(contentViewController.view)
                contentViewController.view.constrainToEdgesOfSuperview()
            }
        }
    }
    fileprivate func refreshTabBar() {
        tabViewBar.refresh()
        tabViewBar.setLeadingBarButtonItems(leftBarButtonItems + (model.visibleViewController?.navigationItem.leftBarButtonItems ?? []))
        tabViewBar.setTrailingBarButtonItems((rightBarButtonItems + (model.visibleViewController?.navigationItem.rightBarButtonItems ?? [])).reversed())
    }
    fileprivate func refreshEmptyView() {
        if let emptyView = self.emptyView {
            if model.viewControllers.isEmpty {
                contentView.addSubview(emptyView)
                emptyView.constrainToEdgesOfSuperview()
            } else {
                emptyView.removeFromSuperview()
            }
        }
    }
}

private class TabViewControllerModel: TabViewBarDataSource, TabViewBarDelegate {
    weak var tabViewController: TabViewController?
    
    private(set) var visibleViewController: UIViewController? {
        didSet {
            tabViewController?.currentContentViewController = visibleViewController
        }
    }
    private(set) var viewControllers: [UIViewController] = []
    
    func activateTab(_ tab: UIViewController) {
        if !viewControllers.contains(tab) {
            viewControllers.append(tab)
        }
        visibleViewController = tab
        
        tabViewController?.refreshTabBar()
        tabViewController?.refreshEmptyView()
    }
    
    func closeTab(_ tab: UIViewController) {
        if let index = viewControllers.index(of: tab) {
            viewControllers.remove(at: index)
        }
        
        // TODO: Pick next vc or some better logic
        visibleViewController = viewControllers.last
        
        tabViewController?.refreshTabBar()
        tabViewController?.refreshEmptyView()
    }
    
    func swapTab(atIndex index: Int, withTabAtIndex atIndex: Int) {
        viewControllers.swapAt(index, atIndex)
        
        tabViewController?.refreshTabBar()
    }
}

private protocol TabViewBarDataSource: class {
    var viewControllers: [UIViewController] { get }
    var visibleViewController: UIViewController? { get }
}

private protocol TabViewBarDelegate: class {
    func activateTab(_ tab: UIViewController)
    func closeTab(_ tab: UIViewController)
    func swapTab(atIndex index: Int, withTabAtIndex atIndex: Int)
}

private class TabViewBar: UIView, Themeable {
    
    weak var barDataSource: TabViewBarDataSource? {
        didSet {
            tabCollectionView.barDataSource = barDataSource
        }
    }
    weak var barDelegate: TabViewBarDelegate? {
        didSet {
            tabCollectionView.barDelegate = barDelegate
        }
    }
    
    private let titleLabel: UILabel
    private let leadingBarButtonStackView: UIStackView
    private let trailingBarButtonStackView: UIStackView
    
    private let tabCollectionView: TabViewTabCollectionView
    private let tabCollectionViewHeightConstraint: NSLayoutConstraint
    private let separator: UIView
    
    init() {
        self.titleLabel = UILabel()
        self.leadingBarButtonStackView = UIStackView()
        self.trailingBarButtonStackView = UIStackView()
        
        self.tabCollectionView = TabViewTabCollectionView()
        tabCollectionViewHeightConstraint = tabCollectionView.heightAnchor.constraint(equalToConstant: 0).withPriority(.defaultHigh)
        self.separator = UIView()
        
        super.init(frame: .zero)
        
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
        
        for stackView in [leadingBarButtonStackView, trailingBarButtonStackView] {
            stackView.alignment = .fill
            stackView.axis = .horizontal
            stackView.distribution = .fill
            stackView.spacing = 15
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
            stackView.setContentHuggingPriority(.required, for: .horizontal)
            addSubview(stackView)
        }
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingBarButtonStackView.trailingAnchor, constant: 5),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingBarButtonStackView.leadingAnchor, constant: -5),
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: barHeight).withPriority(.defaultHigh)
        ])
        
        NSLayoutConstraint.activate([
            leadingBarButtonStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 15),
            leadingBarButtonStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            leadingBarButtonStackView.heightAnchor.constraint(equalToConstant: barHeight).withPriority(.defaultHigh),
            trailingBarButtonStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -15),
            trailingBarButtonStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            trailingBarButtonStackView.heightAnchor.constraint(equalToConstant: barHeight).withPriority(.defaultHigh)
        ])
        
        tabCollectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tabCollectionView)
        NSLayoutConstraint.activate([
            tabCollectionViewHeightConstraint,
            tabCollectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            tabCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tabCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tabCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        separator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(separator)
        NSLayoutConstraint.activate([
            separator.heightAnchor.constraint(equalToConstant: 1).withPriority(.defaultHigh),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func applyTheme(_ theme: Theme) {
        self.backgroundColor = theme.barTintColor
        self.separator.backgroundColor = theme.separatorColor
    }
    
    func setLeadingBarButtonItems(_ barButtonItems: [UIBarButtonItem]) {
        let views = barButtonItems.map { $0.toView() }
        
        for view in leadingBarButtonStackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        for view in views {
            leadingBarButtonStackView.addArrangedSubview(view)
        }
    }
    
    func setTrailingBarButtonItems(_ barButtonItems: [UIBarButtonItem]) {
        let views = barButtonItems.map { $0.toView() }
        
        for view in trailingBarButtonStackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        for view in views {
            trailingBarButtonStackView.addArrangedSubview(view)
        }
    }
    
    func refresh() {
        self.titleLabel.text = barDataSource?.visibleViewController?.title
        tabCollectionView.reloadData()
        
        tabCollectionViewHeightConstraint.constant = (barDataSource?.viewControllers.count ?? 0) > 1 ? tabHeight : 0
        self.layoutIfNeeded() // Apply constraint change immediately.
        
        if let visibleVC = barDataSource?.visibleViewController, let index = barDataSource?.viewControllers.index(of: visibleVC) {
            let indexPath = IndexPath(item: index, section: 0)
            tabCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
}

private class TabViewTabCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    weak var barDataSource: TabViewBarDataSource?
    weak var barDelegate: TabViewBarDelegate?

    fileprivate let layout: UICollectionViewFlowLayout
    
    init() {
        self.layout = SOCollectionViewFlowLayout()
        
        super.init(frame: .zero, collectionViewLayout: layout)
        
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets.zero
        
        self.backgroundColor = nil
        self.showsHorizontalScrollIndicator = false
        self.showsVerticalScrollIndicator = false
        self.alwaysBounceHorizontal = true
        
        self.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(gesture:))))
        
        self.register(TabViewTab.self)
        
        self.delegate = self
        self.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private var viewControllers: [UIViewController] {
        return barDataSource?.viewControllers ?? []
    }
    
    // MARK: UICollectionViewDataSource
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewControllers.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(TabViewTab.self, for: indexPath)
        let tab = viewControllers[indexPath.row]
        
        cell.barDelegate = self.barDelegate
        cell.setTab(tab)
        cell.isSelected = barDataSource?.visibleViewController == tab
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let viewController = viewControllers[indexPath.row]
        
        barDelegate?.activateTab(viewController)
    }
    
    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Allow for reordering tabs

        barDelegate?.swapTab(atIndex: sourceIndexPath.row, withTabAtIndex: destinationIndexPath.row)
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
            guard let selectedIndexPath = self.indexPathForItem(at: gesture.location(in: self)) else {
                break
            }
            self.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            var location = gesture.location(in: gesture.view!)
            location.y = gesture.view!.bounds.size.height / 2
            self.updateInteractiveMovementTargetPosition(location)
        case .ended:
            self.endInteractiveMovement()
        default:
            self.cancelInteractiveMovement()
        }
    }
}

private class TabViewTab: SOCollectionViewCell {
    
    private let titleView: UILabel
    private let closeButton: UIButton
    
    private weak var currentTab: UIViewController?
    weak var barDelegate: TabViewBarDelegate?
    
    private var titleViewLeadingConstraint: NSLayoutConstraint?
    private var titleViewTrailingConstraint: NSLayoutConstraint?
    
    override var isSelected: Bool {
        didSet {
            if let theme = Theme.current {
                self.applyTheme(theme)
            }
        }
    }
    
    override init(frame: CGRect) {
        titleView = UILabel()
        closeButton = UIButton()
        
        super.init(frame: frame)
        
        let buttonSize = CGSize(width: tabHeight, height: tabHeight)
        let buttonImageSize = CGSize(width: 15, height: 15)
        let buttonSizeDiff = CGSize(width: buttonSize.width - buttonImageSize.width, height: buttonSize.height - buttonImageSize.height)
        let buttonInsets = UIEdgeInsets(top: buttonSizeDiff.height / 2, left: buttonSizeDiff.width / 2, bottom: buttonSizeDiff.height / 2, right: buttonSizeDiff.width / 2)

        let closeImg = UIImage(named: "Close", in: Bundle(for: TabViewController.self), compatibleWith: self.traitCollection)
        closeButton.setImage(
            closeImg?.scaled(toSize: CGSize(
                width: buttonSize.width - (buttonInsets.left + buttonInsets.right),
                height: buttonSize.height - (buttonInsets.top + buttonInsets.bottom)
            )
        ), for: .normal)
        closeButton.imageView?.layer.cornerRadius = buttonImageSize.width / 2
        closeButton.imageEdgeInsets = buttonInsets
        
        closeButton.addTarget(self, action: #selector(TabViewTab.closeButtonTapped), for: .touchUpInside)
        
        titleView.textAlignment = .center
        titleView.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        titleView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        titleView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(closeButton)
        contentView.addSubview(titleView)
        
        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            closeButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: buttonSize.width).withPriority(.defaultHigh),
            closeButton.heightAnchor.constraint(equalToConstant: buttonSize.height).withPriority(.defaultHigh)
        ])
        titleViewLeadingConstraint = titleView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        titleViewTrailingConstraint = titleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        NSLayoutConstraint.activate([
            titleViewLeadingConstraint!,
            titleViewTrailingConstraint!,
            titleView.topAnchor.constraint(equalTo: contentView.topAnchor),
            titleView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        // Apply theme settings
        if let theme = Theme.current {
            applyTheme(theme)
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func applyTheme(_ theme: Theme) {
        super.applyTheme(theme)
        
        closeButton.imageView?.tintColor = theme.tabCloseButtonColor
        closeButton.imageView?.backgroundColor = theme.tabCloseButtonBackgroundColor
        
        if self.isSelected {
            self.backgroundColor = nil
            self.closeButton.isHidden = false
            titleView.textColor = theme.tableCellTextColor
            
            // Inset title view by the width of the close button.
            titleViewLeadingConstraint?.constant = tabHeight
            titleViewTrailingConstraint?.constant = -tabHeight
        } else {
            self.backgroundColor = theme.tabBackgroundSelectedColor
            self.closeButton.isHidden = true
            titleView.textColor = theme.tableCellSecondaryTextColor
            titleViewLeadingConstraint?.constant = 0
            titleViewTrailingConstraint?.constant = 0
        }
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
            barDelegate?.closeTab(currentTab)
        }
    }
}

private extension UIBarButtonItem {
    
    func toView() -> UIView {
        if let customView = self.customView {
            return customView
        }
        
        return UIBarButtonItemView(item: self)
    }
}

private class UIBarButtonItemView: UIButton {
    var item: UIBarButtonItem?
    private var itemObservation: NSKeyValueObservation?
    
    convenience init(item: UIBarButtonItem) {
        self.init(type: .system)
        self.item = item
        setTitle(item.title, for: .normal)
        setImage(item.image, for: .normal)
        if let target = item.target, let action = item.action {
            addTarget(target, action: action, for: .touchUpInside)
        }
        itemObservation = item.observe(\.title) { [weak self] item, _ in
            self?.setTitle(item.title, for: .normal)
        }
    }
}
