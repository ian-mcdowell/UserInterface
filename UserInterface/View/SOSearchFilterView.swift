//
//  SOSearchFilterView.swift
//  UserInterface
//
//  Created by Ian McDowell on 4/12/17.
//  Copyright © 2017 Ian McDowell. All rights reserved.
//

import UIKit

public protocol SOSearchFilterViewDelegate: class {
    func containingViewController() -> UIViewController
    
    func toggleValueUpdated(atOptionIndex optionIndex: Int)
    func optionValueUpdated(atOptionIndex optionIndex: Int, valueIndex: Int)
}

public protocol SOSearchFilterViewOption {
    var id: String { get }
    var isToggle: Bool { get }
}

public class SOSearchFilterViewToggleOption: SOSearchFilterViewOption {
    public let id: String
    public var isToggle: Bool { return true }
    
    public let displayNames: (enabled: String, disabled: String)
    public var value: Bool
    
    public init(id: String, displayNames: (enabled: String, disabled: String), value: Bool) {
        self.id = id
        self.displayNames = displayNames
        self.value = value
    }
}

public class SOSearchFilterViewSelectOption: SOSearchFilterViewOption {
    public let id: String
    public var isToggle: Bool { return false }
    
    public var value: String
    public let options: [String]
    
    public init(id: String, value: String, options: [String]) {
        self.id = id
        self.value = value
        self.options = options
    }
}

public class SOSearchFilterView: UICollectionView {
    
    fileprivate let layout: UICollectionViewFlowLayout
    
    public var options: [SOSearchFilterViewOption] = [] {
        didSet {
            self.reloadData()
        }
    }
    public weak var filterViewDelegate: SOSearchFilterViewDelegate?
    
    public required init() {
        let layout = SOCollectionViewFlowLayout()
        self.layout = layout
        super.init(frame: .zero, collectionViewLayout: layout)
        
        dataSource = self
        delegate = self
        backgroundColor = .clear
        alwaysBounceHorizontal = true
        showsHorizontalScrollIndicator = false
        allowsMultipleSelection = true
        
        layout.isPagingEnabled = true
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 20
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        register(SOSearchFilterToggleCell.self)
        register(SOSearchFilterSelectCell.self)
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}

extension SOSearchFilterView: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let option = options[indexPath.item]
        
        let cell: SOSearchFilterCell
        if option is SOSearchFilterViewToggleOption {
            cell = collectionView.dequeueReusableCell(SOSearchFilterToggleCell.self, for: indexPath)
        } else {
            cell = collectionView.dequeueReusableCell(SOSearchFilterSelectCell.self, for: indexPath)
        }
        
        cell.setOption(option)
        
        return cell
    }
}

extension SOSearchFilterView: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let option = self.options[indexPath.item]
        guard let cell = collectionView.cellForItem(at: indexPath) as? SOSearchFilterCell else { return }
        
        if let option = option as? SOSearchFilterViewToggleOption {
            option.value = true
            filterViewDelegate?.toggleValueUpdated(atOptionIndex: indexPath.item)
        } else if let option = option as? SOSearchFilterViewSelectOption {
            collectionView.deselectItem(at: indexPath, animated: false)

            let vc = SOSearchFilterViewSelectPopoverViewController(option: option)
            vc.delegate = self
            
            vc.modalPresentationStyle = .popover
            vc.popoverPresentationController?.sourceView = cell
            vc.popoverPresentationController?.sourceRect = cell.bounds
            vc.popoverPresentationController?.permittedArrowDirections = .up
            vc.popoverPresentationController?.delegate = self
            vc.popoverPresentationController?.backgroundColor = Theme.current.backgroundColor
            
            filterViewDelegate?.containingViewController().present(vc, animated: true, completion: nil)
        }
        
        // Update cell
        cell.setOption(option)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let option = self.options[indexPath.item]
        guard let cell = collectionView.cellForItem(at: indexPath) as? SOSearchFilterCell else { return }
        
        if let option = option as? SOSearchFilterViewToggleOption {
            option.value = false
            filterViewDelegate?.toggleValueUpdated(atOptionIndex: indexPath.item)
        }
        
        // Update cell
        cell.setOption(option)
    }
}

extension SOSearchFilterView: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 160, height: collectionView.frame.size.height - (layout.sectionInset.top + layout.sectionInset.bottom))
    }
}

extension SOSearchFilterView: UIPopoverPresentationControllerDelegate {
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

extension SOSearchFilterView: SOSearchFilterViewSelectPopoverViewControllerDelegate {
    func optionValueSelected(_ option: SOSearchFilterViewSelectOption, value: String) {
        filterViewDelegate?.containingViewController().dismiss(animated: true, completion: nil)
        
        option.value = value
        
        if let index = options.index(where: { $0.id == option.id }), let valueIndex = option.options.index(of: value) {
            filterViewDelegate?.optionValueUpdated(atOptionIndex: index, valueIndex: valueIndex)
        }
        
        reloadData()
    }
}

private class SOSearchFilterCell: SOCollectionViewCell {
    
    let label: UILabel
    
    var isFilled: Bool = false {
        didSet {
            if isFilled {
                backgroundColor = Theme.current.mainColor
                layer.borderWidth = 0
                label.textColor = .white
            } else {
                backgroundColor = .clear
                layer.borderWidth = 1
                label.textColor = Theme.current.tableCellSecondaryTextColor
            }
        }
    }
    
    override init(frame: CGRect) {
        label = UILabel()
        
        super.init(frame: frame)
        
        layer.cornerRadius = 5
        layer.borderColor = UIColor.lightGray.cgColor
        
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular)
        label.textAlignment = .center
        label.baselineAdjustment = .alignCenters
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        label.constrainToEdgesOfSuperview(UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5))
        
        defer {
            isFilled = false
        }
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func setOption(_ option: SOSearchFilterViewOption) {
        
        let name = option.id
        let text = NSMutableAttributedString(string: "\(name): ", attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 12)])
        
        if let option = option as? SOSearchFilterViewToggleOption {
            isFilled = option.value
            
            text.append(NSAttributedString(string: option.value ? option.displayNames.enabled : option.displayNames.disabled))
            
        } else if let option = option as? SOSearchFilterViewSelectOption {
            isFilled = true
            
            text.append(NSAttributedString(string: "\(option.value) ▼"))
        }
        
        label.attributedText = text
    }
}

private class SOSearchFilterToggleCell: SOSearchFilterCell {
    
    override var isSelected: Bool {
        didSet {
            self.isFilled = isSelected
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func setOption(_ option: SOSearchFilterViewOption) {
        super.setOption(option)
    }
}

private class SOSearchFilterSelectCell: SOSearchFilterCell {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func setOption(_ option: SOSearchFilterViewOption) {
        super.setOption(option)
    }
}

private protocol SOSearchFilterViewSelectPopoverViewControllerDelegate: class {
    func optionValueSelected(_ option: SOSearchFilterViewSelectOption, value: String)
}

private class SOSearchFilterViewSelectPopoverViewController: SOViewController {
    
    let option: SOSearchFilterViewSelectOption
    
    let tableView = UITableView()
    
    weak var delegate: SOSearchFilterViewSelectPopoverViewControllerDelegate?
    
    required init(option: SOSearchFilterViewSelectOption) {
        self.option = option
        super.init(nibName: nil, bundle: nil)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(SOTableViewCellText.self)
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        tableView.constrainToEdgesOfSuperview()
        
        tableView.reloadData()
        preferredContentSize = CGSize(width: 200, height: tableView.contentSize.height)
    }
    
}

extension SOSearchFilterViewSelectPopoverViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return option.options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(SOTableViewCellText.self, for: indexPath)
        
        cell.label.text = option.options[indexPath.row]
        cell.accessoryType = option.value == option.options[indexPath.row] ? .checkmark : .none
        
        return cell
    }
}

extension SOSearchFilterViewSelectPopoverViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        delegate?.optionValueSelected(option, value: option.options[indexPath.row])
        tableView.reloadData()
    }
}
