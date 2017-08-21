//
//  PropertySection.swift
//  UserInterface
//
//  Created by Ian McDowell on 2/28/17.
//  Copyright © 2017 Ian McDowell. All rights reserved.
//

import Foundation

public enum PropertySectionSelectionStyle {
    /// No cells in the row will be selected, and no events will fire when they are tapped.
    case none
    /// A cell may be tapped and an event will fire, but it will not appear to be selected.
    case hidden
    /// Only one cell at a time may be selected.
    case single
    /// 0, 1, or many cells may be selected at a time.
    case multiple
}

public class PropertySection {
    public let name: String?
    public let items: [Property]
    public let description: String?
    public let action: PropertyAction?
    public let emptyString: String?
    public let selectionStyle: PropertySectionSelectionStyle
    public let showsActionIfEmpty: Bool
    
    public init(
        name: String? = nil,
        items: [Property] = [],
        description: String? = nil,
        action: PropertyAction? = nil,
        emptyString: String? = nil,
        showsActionIfEmpty: Bool = false,
        selectionStyle: PropertySectionSelectionStyle = .none
    ) {
        self.name = name
        self.items = items
        self.description = description
        self.action = action
        self.emptyString = emptyString
        self.selectionStyle = selectionStyle
        self.showsActionIfEmpty = showsActionIfEmpty
    }
}
