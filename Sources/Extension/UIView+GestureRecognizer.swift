//
//  UIView+GestureRecognizer.swift
//  UserInterface
//
//  Created by Ian McDowell on 1/23/18.
//  Copyright © 2018 Ian McDowell. All rights reserved.
//

import UIKit

public extension UIView {
    
    /// Add a block to be called when the view is tapped. Enables user interaction and adds a UITapGestureRecognizer.
    func onTap(_ block: @escaping () -> Void) {
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(TapGestureRecognizer(action: block))
    }
}

public class TapGestureRecognizer: UITapGestureRecognizer {
    
    private let action: (() -> Void)?
    init(action: @escaping () -> Void) {
        self.action = action
        
        super.init(target: self, action: #selector(recognizerAction))
    }
    
    @objc private func recognizerAction() {
        action?()
    }
}
