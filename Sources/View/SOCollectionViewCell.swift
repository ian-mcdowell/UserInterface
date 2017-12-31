//
//  SOCollectionViewCell.swift
//  Source
//
//  Created by Ian McDowell on 12/28/16.
//  Copyright © 2016 Ian McDowell. All rights reserved.
//
import UIKit

/// Themeable UICollectionViewCell base class.
open class SOCollectionViewCell: UICollectionViewCell, Themeable {

    private var themeObserver: Any?
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        applyCurrentTheme()
        self.themeObserver = NotificationCenter.default.addObserver(forName: Theme.DidChangeNotification, object: nil, queue: .main, using: { [weak self] _ in self?.applyCurrentTheme() })
    }
    
    deinit {
        if let observer = themeObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    open func applyTheme(_ theme: Theme) {
    }
}
