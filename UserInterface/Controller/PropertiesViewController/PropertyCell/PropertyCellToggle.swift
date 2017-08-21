//
//  PropertyCellToggle.swift
//  UserInterface
//
//  Created by Ian McDowell on 2/28/17.
//  Copyright © 2017 Ian McDowell. All rights reserved.
//

import Foundation

internal class PropertyCellToggle: InternalPropertyCell {
    
    private var switchView: UISwitch!
    
    override class var style: UITableViewCellStyle {
        return .subtitle
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        switchView = UISwitch()
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        switchView.addTarget(self, action: #selector(PropertyCellToggle.notifyValueChanged), for: .valueChanged)
        self.accessoryView = switchView
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setProperty(_ property: Property, section: PropertySection, propertiesViewController: PropertiesViewController) {
        super.setProperty(property, section: section, propertiesViewController: propertiesViewController)
        
        self.setSwitchOn(property._selected)
    }
    
    func setSwitchOn(_ on: Bool, notify: Bool = false) {
        switchView.isOn = on
        
        if notify {
            notifyValueChanged()
        }
    }
    
    func isSwitchOn() -> Bool {
        return self.switchView.isOn
    }
    
    @objc func notifyValueChanged() {
        property?.setSelected(switchView.isOn, propigate: false)
    }
}
