//
//  TextProperty.swift
//  UserInterface
//
//  Created by Ian McDowell on 2/28/17.
//  Copyright © 2017 Ian McDowell. All rights reserved.
//
import UIKit

public class TextProperty: Property {
    public let autoCorrect: UITextAutocorrectionType
    public let autoCapitalize: UITextAutocapitalizationType
    public let keyboardType: UIKeyboardType
    public let secure: Bool
    
    /// If this property is not nil, the name will be placed on the left side of the cell as a label. If the property is nil, the name will be the placeholder of the text field.
    public let placeholder: String?
    
    internal var textField: UITextField?
    
    public init(
        ID: String? = nil,
        name: String,
        value: String? = nil,
        action: PropertyAction? = nil,
        editAction: PropertyAction? = nil,
        icon: UIImage? = nil,
        selected: Bool = false,
        style: PropertyStyle = .text,
        rowActions: [UITableViewRowAction]? = nil,
        customAccessoryView: UIView? = nil,
        data: Any? = nil,
        
        autoCorrect: UITextAutocorrectionType = .default,
        autoCapitalize: UITextAutocapitalizationType = .sentences,
        keyboardType: UIKeyboardType = .default,
        secure: Bool = false,
        placeholder: String? = nil
    ) {
        self.autoCorrect = autoCorrect
        self.autoCapitalize = autoCapitalize
        self.keyboardType = keyboardType
        self.secure = secure
        self.placeholder = placeholder
        
        super.init(ID: ID, name: name, value: value, action: action, editAction: editAction, icon: icon, selected: selected, style: style, rowActions: rowActions, customAccessoryView: customAccessoryView, data: data)
    }
    
    public override func activate() {
        textField?.becomeFirstResponder()
    }
}
