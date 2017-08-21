//
//  PropertiesViewController.swift
//  Source
//
//  Created by Ian McDowell on 8/8/16.
//  Copyright © 2016 Ian McDowell. All rights reserved.
//

public typealias PropertyUpdaterKey = String

public let PropertyUpdaterKeySelected: PropertyUpdaterKey = "selected"
public let PropertyUpdaterKeyValue: PropertyUpdaterKey = "value"

public protocol PropertyUpdating: class {
    func propertyUpdaterValueChanged(updater: AnyObject, key: PropertyUpdaterKey, value: Any?)
}

open class PropertiesViewController: SOViewController, UITableViewDataSource, UITableViewDelegate, PropertyUpdating {

    public var tableView: UITableView
    public var emptyView: UILabel

    private var loadingView: UIView
    private var loadingIndicator: UIActivityIndicatorView
    public var loading: Bool = false {
        didSet {
            if loading && loadingView.superview == nil {
                self.view.addSubview(loadingView)
                loadingView.constrainToEdgesOfSuperview()
                
            } else if !loading && loadingView.superview != nil {
                loadingView.removeFromSuperview()
            }
        }
    }

    open var properties = [PropertySection]() {
        didSet {
            for propertySection in properties {
                for property in propertySection.items {
                    property.propertyUpdater = self
                }
            }

            tableView.reloadData()

            if self.properties.isEmpty {
                self.showEmptyView()
            } else {
                self.hideEmptyView()
            }
        }
    }

    public weak var propertyUpdater: PropertyUpdating?

    public init() {
        emptyView = UILabel()
        tableView = UITableView(frame: CGRect.zero, style: .grouped)

        loadingView = UIView()
        loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)

        super.init(nibName: nil, bundle: nil)

        emptyView.numberOfLines = 0
        emptyView.textAlignment = .center
        emptyView.text = emptyString()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.allowsSelectionDuringEditing = true

        tableView.register(PropertyCell.self)
        tableView.register(PropertyCellRight.self)
        tableView.register(PropertyCellSubtitle.self)
        tableView.register(PropertyCellToggle.self)
        tableView.register(PropertyCellText.self)
        tableView.register(PropertyCellTextWithLabel.self)
        tableView.register(PropertyActionCell.self)
        
        for customClass in customPropertyCellClasses {
            tableView.register(customClass)
        }

        view.addSubview(tableView)
        tableView.constrainToEdgesOfSuperview()

        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.startAnimating()
        loadingView.addSubview(loadingIndicator)
        loadingIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor).isActive = true
        loadingIndicator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor).isActive = true
        
        self.loading = true
    }

    open override func applyTheme(_ theme: Theme) {
        super.applyTheme(theme)

        view.backgroundColor = theme.backgroundColor

        emptyView.textColor = theme.emptyTextColor

        loadingIndicator.color = theme.tableCellSecondaryTextColor
        loadingView.backgroundColor = theme.backgroundColor

        tableView.reloadData()
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        reload()

        NotificationCenter.default.addObserver(self, selector: #selector(PropertiesViewController.keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PropertiesViewController.keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    /// Override this to allow for custom cell classes to be alongside properties
    open var customPropertyCellClasses: [PropertyCell.Type] { return [] }
    
    open func willReload() { }

    public func reload() {
        self.reloadWithCompletion(nil)
    }
    
    public func reloadWithCompletion(_ completion: (() -> Void)?) {
        self.willReload()
        
        // Get the Properties object
        let propertiesResult = self.loadProperties()

        // If we have properties right away
        if let properties = propertiesResult.properties {
            self.setProperties(properties)
            completion?()
        } else if let deferred = propertiesResult.deferred {

            // Only show loading indicator if there is nothing to show.
            if self.properties.count == 0 {
                self.loading = true
            }
            deferred({ properties in
                assert(Thread.isMainThread, "Deferred property loader must callback on main thread.")

                self.setProperties(properties)
                
                
                completion?()
            })
        } else {
            assertionFailure("Neither properties or deferred property loader found when calling loadProperties()")
        }
    }

    private func setProperties(_ properties: [PropertySection]) {
        self.loading = false
        
        self.properties = properties.filter({ section -> Bool in
            return !(section.emptyString == nil && section.items.count == 0)
        })
    }

    open func loadProperties() -> Properties {
        return .properties([])
    }
    
    public func property(withID id: String) -> Property? {
        return self.properties.flatMap { $0.items }.first(where: { $0.ID == id })
    }

    private func showEmptyView() {
        self.tableView.isHidden = true

        emptyView.text = emptyString()

        view.addSubview(emptyView)
        emptyView.constrainToEdgesOfSuperview(UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
    }

    private func hideEmptyView() {
        self.tableView.isHidden = false

        emptyView.removeFromSuperview()
    }

    open func emptyString() -> String {
        return ""
    }

    open func willTransitionToViewController(_ viewController: UIViewController, withProperty property: Property?) {
        (viewController as? PropertiesViewController)?.propertyUpdater = self
    }

    open func propertyUpdaterValueChanged(updater: AnyObject, key: PropertyUpdaterKey, value: Any?) {
    }

    private var keyboardOpen = false

    @objc private func keyboardWillShow(_ note: Notification) {
        if keyboardOpen {
            return
        }

        if self.modalPresentationStyle == .formSheet || self.navigationController?.modalPresentationStyle == .formSheet {
            return
        }
        if self.modalPresentationStyle == .popover || self.navigationController?.modalPresentationStyle == .popover {
            return
        }

        guard let keyInfo = (note as NSNotification).userInfo else {
            return
        }
        guard var keyboardFrame = (keyInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue else {
            return
        }
        keyboardFrame = self.tableView.convert(keyboardFrame, from: nil)
        let intersect = keyboardFrame.intersection(self.tableView.bounds)
        if !intersect.isNull {

            guard let duration = (keyInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue else {
                return
            }

            var inset = self.tableView.contentInset
            inset.bottom = intersect.size.height

            var scrollIndicatorInsets = self.tableView.scrollIndicatorInsets
            scrollIndicatorInsets.bottom = intersect.size.height

            UIView.animate(withDuration: duration, animations: {
                self.tableView.contentInset = inset
                self.tableView.scrollIndicatorInsets = scrollIndicatorInsets
            })
        }

        keyboardOpen = true
    }

    @objc private func keyboardWillHide(_ note: Notification) {
        if !keyboardOpen {
            return
        }

        if self.modalPresentationStyle == .formSheet || self.navigationController?.modalPresentationStyle == .formSheet {
            return
        }
        if self.modalPresentationStyle == .popover || self.navigationController?.modalPresentationStyle == .popover {
            return
        }

        guard let keyInfo = (note as NSNotification).userInfo else {
            return
        }
        guard let duration = (keyInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue else {
            return
        }

        var inset = self.tableView.contentInset
        inset.bottom = 0

        var scrollIndicatorInsets = self.tableView.scrollIndicatorInsets
        scrollIndicatorInsets.bottom = 0

        UIView.animate(withDuration: duration, animations: {
            self.tableView.contentInset = inset
            self.tableView.scrollIndicatorInsets = scrollIndicatorInsets
        })
        keyboardOpen = false
    }

    // MARK: UITableViewDataSource

    public func numberOfSections(in tableView: UITableView) -> Int {
        return properties.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let propertySection = properties[section]

        var count = 0
        if propertySection.items.count == 0 {
            if propertySection.emptyString != nil {
                count = count + 1
            }
        } else {
            count = count + propertySection.items.count
        }

        if propertySection.action != nil && (propertySection.items.count != 0 || propertySection.showsActionIfEmpty) {
            count = count + 1
        }

        return count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let propertySection = properties[indexPath.section]

        if propertySection.items.count == 0 && propertySection.emptyString != nil && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(PropertyCell.self, for: indexPath)

            cell.textLabel?.text = propertySection.emptyString
            cell.textLabel?.textColor = Theme.current.tableCellTextColor
            cell.selectedBackgroundView?.backgroundColor = Theme.current.tableCellBackgroundSelectedColor

            return cell
        } else if indexPath.row >= propertySection.items.count {
            let cell = tableView.dequeueReusableCell(PropertyActionCell.self, for: indexPath)

            cell.setAction(propertySection.action!, propertiesViewController: self)

            return cell
        } else {
            let property = propertySection.items[indexPath.row]

            var type: PropertyCell.Type
            switch property.style {
            case .subtitle:
                type = PropertyCellSubtitle.self
            case .right:
                type = PropertyCellRight.self
            case .toggle:
                type = PropertyCellToggle.self
            case .text:
                if let property = property as? TextProperty, property.placeholder != nil {
                    type = PropertyCellTextWithLabel.self
                } else {
                    type = PropertyCellText.self
                }
            case let .custom(cellClass):
                type = cellClass
            }

            let cell = tableView.dequeueReusableCell(type, for: indexPath)

            cell.setProperty(property, section: propertySection, propertiesViewController: self)

            return cell
        }
    }
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let hfView = view as? UITableViewHeaderFooterView {
            hfView.textLabel?.textColor = Theme.current.tableHeaderTextColor
        }
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return properties[section].name
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return properties[section].description
    }

    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

        if indexPath.section < 0 || indexPath.section >= properties.count {
            return false
        }

        // If there are actions, return true
        let items = properties[indexPath.section].items
        if indexPath.row < items.count {
            let item = items[indexPath.row]
            return item.rowActions != nil && item.rowActions!.count > 0
        }

        return false
    }

    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        if indexPath.section < 0 || indexPath.section >= properties.count {
            return nil
        }

        let items = properties[indexPath.section].items
        if indexPath.row < items.count {
            return items[indexPath.row].rowActions
        }

        return nil
    }

    // for some reason this is required?
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {}

    // MARK: UITableViewDelegate

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let propertySection = properties[indexPath.section]

        if propertySection.items.count == 0 && propertySection.emptyString != nil && indexPath.row == 0 {
            // empty row tapped

        } else if indexPath.row >= propertySection.items.count {
            propertySection.action?.perform(from: self)
        } else {
            let property = propertySection.items[indexPath.row]

            if propertySection.selectionStyle == .multiple {
                property.selected = !property.selected

                tableView.reloadRows(at: [indexPath], with: .none)
            } else if propertySection.selectionStyle == .single || propertySection.selectionStyle == .hidden {
                for p in propertySection.items {
                    p.selected = false
                }

                property.selected = true
                tableView.reloadSections(IndexSet(integer: indexPath.section), with: .none)
            }
            if tableView.isEditing {
                property.editAction?.perform(from: self)
            } else {
                property.action?.perform(from: self)
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
    }
}










