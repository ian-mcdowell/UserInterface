//
//  UICollectionView+Custom.swift
//  Source
//
//  Created by Ian McDowell on 12/27/16.
//  Copyright © 2016 Ian McDowell. All rights reserved.
//
import UIKit

extension UICollectionView {

    /// Registers a cell for reuse with the collection view. The reuse identifier is set to the class name.
    ///
    /// - Parameter cellClass: class of a UICollectionViewCell
    public func register(_ cellClass: UICollectionViewCell.Type) {
        self.register(cellClass, forCellWithReuseIdentifier: NSStringFromClass(cellClass))
    }

    /// Registers a view for reuse with the collection view.
    ///
    /// - Parameters:
    ///   - viewClass: class of any kind of reusable view
    ///   - elementKind: kind of the reusable view
    public func register(_ viewClass: UICollectionReusableView.Type, forSupplementaryViewOfKind elementKind: String) {
        self.register(viewClass, forSupplementaryViewOfKind: elementKind, withReuseIdentifier: NSStringFromClass(viewClass))
    }

    /// Dequeues a reusable cell with the reuse identifier equal to the class name.
    ///
    /// - Parameters:
    ///   - cellClass: class of the cell
    ///   - indexPath: indexPath for the cell
    public func dequeueReusableCell<T: UICollectionViewCell>(_ cellClass: T.Type, for indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(cellClass), for: indexPath) as! T
    }

    /// Dequeues a reusable supplementary view with the reuse identifier equal to the class name.
    ///
    /// - Parameters:
    ///   - elementKind: the kind of reusable view
    ///   - viewClass: class of the reusable view
    ///   - indexPath: indexPath for the cell
    public func dequeueReusableSupplementaryView<T: UICollectionReusableView>(ofKind elementKind: String, viewClass: T.Type, for indexPath: IndexPath) -> T {
        return self.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: NSStringFromClass(viewClass), for: indexPath) as! T
    }
}
