//
//  Property.swift
//  UserInterface
//
//  Created by Ian McDowell on 2/28/17.
//  Copyright © 2017 Ian McDowell. All rights reserved.
//
import UIKit

public enum PropertyStyle {
    case subtitle, right, toggle, text
    
    case custom(PropertyCell.Type)
}

public class Property {
    public let ID: String?
    public let name: String
    public var value: String? {
        get {
            return getValue()
        }
        set {
            setValue(newValue)
        }
    }
    
    public let action: PropertyAction?
    public let editAction: PropertyAction?
    public let icon: UIImage?
    public let rowActions: [UITableViewRowAction]?
    public let data: Any?
    public let style: PropertyStyle
    public let customAccessoryView: UIView?
    public var dontScaleIcon: Bool = false
    
    public var selected: Bool {
        get {
            return getSelected()
        }
        set {
            setSelected(newValue)
        }
    }
    
    public init(
        ID: String? = nil,
        name: String,
        value: String? = nil,
        action: PropertyAction? = nil,
        editAction: PropertyAction? = nil,
        icon: UIImage? = nil,
        selected: Bool = false,
        style: PropertyStyle = .right,
        rowActions: [UITableViewRowAction]? = nil,
        customAccessoryView: UIView? = nil,
        data: Any? = nil
    ) {
        self.ID = ID
        self.name = name
        self.action = action
        self.editAction = editAction
        self.icon = icon
        self.rowActions = rowActions
        self.data = data
        self.style = style
        self.customAccessoryView = customAccessoryView
        
        self.selected = selected
        self.value = value
    }
    
    public func activate() {
    }
    
    internal weak var _propertiesViewController: PropertiesViewController?
    internal var _value: String?
    internal var _selected: Bool = false
    internal var _currentCell: InternalPropertyCell?
    
    
    internal func setValue(_ value: String?, propigate: Bool = true) {
        
        if (propigate) {
            _currentCell?._value = value
        }
        
        if _value != value {
            _value = value
            _propertiesViewController?.propertyValueChanged(self)
        }
    }
    
    internal func getValue() -> String? {
        if let v = _currentCell?._value {
            _value = v
            return v
        }
        return _value
    }
    
    internal func setSelected(_ selected: Bool, propigate: Bool = true) {
        
        if propigate {
            (_currentCell as? PropertyCellToggle)?.setSwitchOn(selected)
        }
        
        if _selected != selected {
            _selected = selected
            _propertiesViewController?.propertySelected(self)
        }
    }
    
    internal func getSelected() -> Bool {
        if let v = (_currentCell as? PropertyCellToggle)?.isSwitchOn() {
            _selected = v
            return v
        }
        return _selected
    }
}

extension Property: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "<\(type(of: self))> - \(self.name) - \(self.value ?? "No value")"
    }
    
    
}
