//
//  PropertyCell.swift
//  UserInterface
//
//  Created by Ian McDowell on 2/28/17.
//  Copyright © 2017 Ian McDowell. All rights reserved.
//

import Foundation

open class PropertyCell: UITableViewCell {
    
    open class var style:  UITableViewCellStyle {
        return .default
    }
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: type(of: self).style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func setup() {
        
    }
    
    open func setProperty(_ property: Property, section: PropertySection, propertiesViewController: PropertiesViewController) {
        
    }
}

internal class InternalPropertyCell: PropertyCell {
    
    internal weak var property: Property? {
        willSet {
            property?._currentCell = nil
        }
        didSet {
            property?._currentCell = self
        }
    }
    
    internal var _value: String? {
        set {
            detailTextLabel?.text = newValue
        }
        get {
            return detailTextLabel?.text
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.detailTextLabel?.numberOfLines = 1
        self.detailTextLabel?.adjustsFontSizeToFitWidth = true
        self.detailTextLabel?.minimumScaleFactor = 0.5
        self.textLabel?.numberOfLines = 1
        self.textLabel?.adjustsFontSizeToFitWidth = true
        self.textLabel?.minimumScaleFactor = 0.5
        
        self.selectedBackgroundView = UIView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setProperty(_ property: Property, section: PropertySection, propertiesViewController: PropertiesViewController) {
        self.property = property
        
        self.textLabel?.textColor = Theme.current.tableCellTextColor
        self.detailTextLabel?.textColor = Theme.current.tableCellTextColor
        self.selectedBackgroundView?.backgroundColor = Theme.current.tableCellBackgroundSelectedColor
        
        self.textLabel?.text = property.name
        self.detailTextLabel?.text = property.value
        
        if property.dontScaleIcon {
            self.imageView?.image = property.icon
        } else {
            self.imageView?.image = property.icon?.scaled(toWidth: 25)
        }
        
        self.selectionStyle = .none
        if section.selectionStyle != .none && section.selectionStyle != .hidden {
            if property.selected {
                self.accessoryType = .checkmark
            } else {
                self.accessoryType = .none
            }
        } else {
            if property.action != nil {
                self.accessoryType = .disclosureIndicator
                self.selectionStyle = .default
            } else {
                self.accessoryType = .none
            }
        }
        
        if property.editAction != nil {
            self.editingAccessoryType = .disclosureIndicator
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.textLabel?.text = nil
        self.detailTextLabel?.text = nil
        
        self.textLabel?.textColor = UIColor.black
    }

}
