//
//  PropertyCellRight.swift
//  UserInterface
//
//  Created by Ian McDowell on 2/28/17.
//  Copyright © 2017 Ian McDowell. All rights reserved.
//

import Foundation

internal class PropertyCellRight: InternalPropertyCell {
    
    override class var style: UITableViewCellStyle {
        return .value1
    }
    
    override func setProperty(_ property: Property, section: PropertySection, propertiesViewController: PropertiesViewController) {
        super.setProperty(property, section: section, propertiesViewController: propertiesViewController)
        
        self.detailTextLabel?.textColor = Theme.current.tableCellSecondaryTextColor
    }
}
