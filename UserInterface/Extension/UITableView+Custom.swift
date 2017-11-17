//
//  UITableView+Custom.swift
//  Source
//
//  Created by Ian McDowell on 12/27/16.
//  Copyright © 2016 Ian McDowell. All rights reserved.
//
import UIKit

extension UITableView {

    /// Registers a cell for reuse with the tableView. The reuse identifier is set to the class name.
    ///
    /// - Parameter cellClass: class of a UITableViewCell
    public func register(_ cellClass: UITableViewCell.Type) {
        self.register(cellClass, forCellReuseIdentifier: NSStringFromClass(cellClass))
    }

    /// Dequeues a reusable cell with the reuse identifier equal to the class name.
    ///
    /// - Parameters:
    ///   - cellClass: class of the cell
    ///   - indexPath: indexPath for the cell
    public func dequeueReusableCell<T: UITableViewCell>(_ cellClass: T.Type, for indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withIdentifier: NSStringFromClass(cellClass), for: indexPath) as! T
    }
}
