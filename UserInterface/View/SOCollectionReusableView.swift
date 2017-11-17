//
//  SOCollectionReusableView.swift
//  UserInterface
//
//  Created by Ian McDowell on 9/12/17.
//  Copyright © 2017 Ian McDowell. All rights reserved.
//

import UIKit

open class SOCollectionReusableView: UICollectionReusableView, Themeable {
    
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
        if let observer = self.themeObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    open func applyTheme(_ theme: Theme) {
    }

}
