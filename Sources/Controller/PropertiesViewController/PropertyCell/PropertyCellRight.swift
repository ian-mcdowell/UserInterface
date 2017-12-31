//
//  PropertyCellRight.swift
//  UserInterface
//
//  Created by Ian McDowell on 2/28/17.
//  Copyright © 2017 Ian McDowell. All rights reserved.
//
import UIKit

internal class PropertyCellRight: InternalPropertyCell {
    
    override class var style: UITableViewCellStyle {
        return .value1
    }
    
    override func applyTheme(_ theme: Theme) {
        super.applyTheme(theme)
        
        self.detailTextLabel?.textColor = theme.tableCellSecondaryTextColor
    }
}
