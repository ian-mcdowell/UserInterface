//
//  PropertyCellText.swift
//  UserInterface
//
//  Created by Ian McDowell on 2/28/17.
//  Copyright © 2017 Ian McDowell. All rights reserved.
//
import UIKit

internal class PropertyCellText: InternalPropertyCell {
    
    override var _value: String? {
        set {
            textField.text = _value
        }
        get {
            return textField.text
        }
    }
    
    let textField: UITextField
    
    override class var style: UITableViewCellStyle {
        return .default
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        textField = UITextField()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(textField)
        setupTextField()
        
        self.textField.addTarget(self, action: #selector(PropertyCellText.textFieldChanged), for: .editingChanged)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setProperty(_ property: Property, section: PropertySection, propertiesViewController: PropertiesViewController) {
        self.property = property
        
        textField.text = property._value
        
        if let property = property as? TextProperty {
            property.textField = textField
            
            textField.autocorrectionType = property.autoCorrect
            textField.autocapitalizationType = property.autoCapitalize
            textField.keyboardType = property.keyboardType
            textField.isSecureTextEntry = property.secure
            
            // If the placeholder is shown in the textfield, the name of the property should appear in the left label.
            if property.placeholder != nil {
                textLabel?.text = property.name
            }
            
            self.setupTextFieldPlaceholderWithTextProperty(property, propertiesViewController)
        }
        
        self.selectionStyle = .none
    }
    
    func setupTextField() {
        textField.constrainToEdgesOfSuperview(UIEdgeInsets(top: 12, left: 15, bottom: 12, right: 15))
    }
    
    
    /// Sets up the text field's placeholder with the TextProperty. This should be overridden and super should not be called.
    func setupTextFieldPlaceholderWithTextProperty(_ property: TextProperty, _ propertiesViewController: PropertiesViewController) {
        
        textField.attributedPlaceholder = NSAttributedString(
            string: property.name,
            attributes: [
                NSAttributedStringKey.foregroundColor: Theme.current?.placeholderTextColor ?? .lightGray
            ]
        )
        
        if type(of: self) == PropertyCellText.self && property.placeholder != nil {
            assertionFailure("A PropertyCellTextWithLabel should be used if the placeholder of a TextProperty is not nil.")
        }
    }
    
    // MARK: UITextFieldDelegate
    
    @objc func textFieldChanged() {
        self.property?.setValue(self.textField.text, propigate: false)
    }
    
    override func applyTheme(_ theme: Theme) {
        super.applyTheme(theme)
        textLabel?.textColor = theme.tableCellTextColor
        
        textField.textColor = theme.tableCellTextColor
    }
}

internal class PropertyCellTextWithLabel: PropertyCellText {
    
    override class var style: UITableViewCellStyle {
        return .value1
    }
    
    override func setupTextField() {
        guard let textLabel = self.textLabel else {
            return
        }
        
        textField.textAlignment = .right
        textField.adjustsFontSizeToFitWidth = true
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: textLabel.trailingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            textField.topAnchor.constraint(equalTo: textLabel.topAnchor),
            textField.bottomAnchor.constraint(equalTo: textLabel.bottomAnchor)
        ])
    }
    
    override func setupTextFieldPlaceholderWithTextProperty(_ property: TextProperty, _ propertiesViewController: PropertiesViewController) {
        
        textField.attributedPlaceholder = NSAttributedString(
            string: property.placeholder ?? "",
            attributes: [
                NSAttributedStringKey.foregroundColor: Theme.current?.placeholderTextColor ?? .lightGray
            ]
        )
        
        if type(of: self) == PropertyCellTextWithLabel.self && property.placeholder == nil {
            assertionFailure("A PropertyCellText should be used if the placeholder of a TextProperty is nil.")
        }
    }
}
