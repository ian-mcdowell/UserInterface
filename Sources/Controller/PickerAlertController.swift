//
//  PickerAlertController.swift
//  Source
//
//  Created by Ian McDowell on 1/29/17.
//  Copyright © 2017 Ian McDowell. All rights reserved.
//
import UIKit

public enum PickerAlertControllerStyle {
    case table, picker
}

open class PickerAlertController<T: Equatable>: UIAlertController {
    
    let style: PickerAlertControllerStyle
    
    public init(title: String? = nil, message: String? = nil, style: PickerAlertControllerStyle = .picker) {
        self.style = style
        super.init(nibName: nil, bundle: nil)
        self.title = title
        self.message = message
    }
    
    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    open func name(forItem item: T) -> String {
        assertionFailure("Please override the name(forItem:) method of PickerAlertController")
        return ""
    }
    
    open func subtitle(forItem item: T) -> String? {
        return nil
    }
    
    open func selectedItem(_ item: T) {
        
    }
    
    public func present(from vc: UIViewController, items: [T], selectedItem: T? = nil, callback: @escaping (_ selectedItem: T?) -> Void) {
        
        let pickerViewController: PickerBaseViewController<T>
        switch style {
        case .picker:
            pickerViewController = PickerViewController<T>()
        case .table:
            pickerViewController = PickerTableViewController<T>()
        }
        
        pickerViewController.items = items
        pickerViewController.selectedItem = selectedItem
        pickerViewController.pickerAlertController = self

        
        // PRIVATE: Setting a content view controller is a private thing.
        let selector = NSSelectorFromString("setContentViewController:")
        if self.responds(to: selector) {
            self.perform(selector, with: pickerViewController)
        }
        
        self.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .destructive,
                handler: { _ in
                    callback(nil)
                }
            )
        )
        
        self.addAction(
            UIAlertAction(
                title: "OK",
                style: .default,
                handler: { _ in
                    callback(pickerViewController.selectedItem)
                }
            )
        )
        
        vc.present(self, animated: true, completion: nil)
    }
    
}

private class PickerBaseViewController<T: Equatable>: UIViewController {
    var selectedItem: T? = nil
    var items: [T] = []
    weak var pickerAlertController: PickerAlertController<T>?
}

private class PickerViewController<T: Equatable>: PickerBaseViewController<T>, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let pickerView = UIPickerView()
    
    override func loadView() {
        self.view = pickerView
        pickerView.delegate = self
    }
    
    override var items: [T] {
        didSet {
            pickerView.reloadAllComponents()
            self.preferredContentSize = pickerView.intrinsicContentSize
        }
    }
    
    override var selectedItem: T? {
        didSet {
            pickerView.reloadAllComponents()
            self.preferredContentSize = pickerView.intrinsicContentSize
            scrollToSelectedItem()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        scrollToSelectedItem()
    }
    
    func scrollToSelectedItem() {
        if let item = selectedItem, let index = items.index(of: item) {
            pickerView.selectRow(index, inComponent: 0, animated: true)
        } else {
            pickerView.selectRow(0, inComponent: 0, animated: true)
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let components: [String?] = [
            self.pickerAlertController?.name(forItem: items[row]),
            self.pickerAlertController?.subtitle(forItem: items[row])
        ]
        return components.flatMap({ $0 }).joined(separator: " - ")
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let item = items[row]
        selectedItem = item
        pickerAlertController?.selectedItem(item)
    }
}

private class PickerTableViewController<T: Equatable>: PickerBaseViewController<T>, UITableViewDelegate, UITableViewDataSource {
    
    private let tableView = UITableView(frame: .zero, style: .plain)

    override func loadView() {
        self.view = tableView
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SOTableViewCellSubtitle.self)
    }
    
    override var items: [T] {
        didSet {
            tableView.reloadData()
            self.preferredContentSize = tableView.contentSize
        }
    }
    
    override var selectedItem: T? {
        didSet {
            tableView.reloadData()
            self.preferredContentSize = tableView.contentSize
            if let item = selectedItem, let index = items.index(of: item) {
                tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .middle, animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(SOTableViewCellSubtitle.self)
        tableView.bounces = false
        tableView.backgroundColor = .clear
        
        tableView.reloadData()
        self.preferredContentSize = tableView.contentSize
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(SOTableViewCellSubtitle.self, for: indexPath)
        
        let item = items[indexPath.row]
        cell.textLabel?.text = pickerAlertController?.name(forItem: item)
        cell.detailTextLabel?.text = pickerAlertController?.subtitle(forItem: item)
        
        cell.accessoryType = item == selectedItem ? .checkmark : .none
        cell.backgroundColor = .clear
        cell.tintColor = .black
        cell.selectedBackgroundView?.backgroundColor = .lightGray
        cell.textLabel?.textColor = .black
        cell.detailTextLabel?.textColor = .black
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let item = items[indexPath.row]
        selectedItem = item
        pickerAlertController?.selectedItem(item)
    }
}
