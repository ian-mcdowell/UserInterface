//
//  SOEmptyCell.swift
//  UserInterface
//
//  Created by Ian McDowell on 10/26/17.
//  Copyright © 2017 Ian McDowell. All rights reserved.
//

import UIKit

open class SOEmptyCell: SOCollectionViewCell {
    public let label: UILabel
    
    public override init(frame: CGRect) {
        self.label = UILabel()
        super.init(frame: frame)
        
        backgroundColor = .clear
        label.numberOfLines = 0
        label.textAlignment = .center
        
        contentView.addSubview(label)
        label.constrainToEdgesOfSuperview()
    }
    
    public required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    open override func applyTheme(_ theme: Theme) {
        label.textColor = theme.emptyTextColor
    }
    
}
