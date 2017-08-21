//
//  SOPickerAlertController.swift
//  Source
//
//  Created by Ian McDowell on 1/29/17.
//  Copyright © 2017 Ian McDowell. All rights reserved.
//

open class SOPickerAlertController<T: Equatable>: UIAlertController {
    
    internal var pickerTableViewController: SOPickerTableViewController<T>
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        pickerTableViewController = SOPickerTableViewController<T>(style: .plain)
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        pickerTableViewController.pickerAlertController = self
        
        // PRIVATE: Setting a content view controller is a private thing.
        let selector = NSSelectorFromString("setContentViewController:")
        if self.responds(to: selector) {
            self.perform(selector, with: pickerTableViewController)
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func layoutCell(_ cell: SOTableViewCell, forItem item: T) {
        
    }
    
    open func selectedItem(_ item: T) {
        
    }
    
    public func present(from vc: UIViewController, items: [T], selectedItem: T? = nil, callback: @escaping (_ selectedItem: T?) -> Void) {
        
        pickerTableViewController.items = items
        pickerTableViewController.selectedItem = selectedItem
        
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
                    callback(self.pickerTableViewController.selectedItem)
                }
            )
        )
        
        vc.present(self, animated: true, completion: nil)
    }
    
}

internal class SOPickerTableViewController<T: Equatable>: UITableViewController {
    
    internal var items = [T]() {
        didSet {
            tableView.reloadData()
            self.preferredContentSize = tableView.contentSize
        }
    }
    weak var pickerAlertController: SOPickerAlertController<T>!
    
    public var selectedItem: T? {
        didSet {
            tableView.reloadData()
            self.preferredContentSize = tableView.contentSize
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(SOTableViewCellSubtitle.self, for: indexPath)
        
        let item = items[indexPath.row]
        pickerAlertController.layoutCell(cell, forItem: item)
        
        cell.accessoryType = item == selectedItem ? .checkmark : .none
        cell.backgroundColor = .clear
        cell.tintColor = .black
        cell.selectedBackgroundView?.backgroundColor = .lightGray
        cell.textLabel?.textColor = .black
        cell.detailTextLabel?.textColor = .black
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        let item = items[indexPath.row]
        selectedItem = item
        
        pickerAlertController.selectedItem(item)
    }
}
