//
//  PropertyAction.swift
//  UserInterface
//
//  Created by Ian McDowell on 2/28/17.
//  Copyright © 2017 Ian McDowell. All rights reserved.
//

import UIKit

public class PropertyAction {
    public var name: String?
    public var icon: UIImage?
    
    public var destinationViewController: UIViewController.Type?
    public weak var target: AnyObject?
    public var action: Selector?
    
    public var block: (() -> Void)?
    
    public init(name: String? = nil, destinationViewController: UIViewController.Type? = nil, icon: UIImage? = nil) {
        self.name = name
        self.destinationViewController = destinationViewController
        self.icon = icon
    }
    
    public init(name: String? = nil, target: AnyObject?, action: Selector, icon: UIImage? = nil) {
        self.name = name
        self.icon = icon
        self.target = target
        self.action = action
    }
    
    public init(name: String? = nil, block: @escaping () -> Void, icon: UIImage? = nil) {
        self.name = name
        self.icon = icon
        self.block = block
    }
    
    // Performs this action from the properties view controller
    internal func perform(from propertiesViewController: PropertiesViewController) {
        if let vc = self.destinationViewController {
            let viewController = vc.init()
            propertiesViewController.navigationController?.pushViewController(viewController, animated: true)
        } else if let target = self.target, let action = self.action {
            _ = target.perform(action)
        } else if let block = self.block {
            block()
        }
    }
}

internal class PropertyActionCell: SOTableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: UITableViewCellStyle.default, reuseIdentifier: reuseIdentifier)
        
        self.accessoryType = .disclosureIndicator
        self.selectedBackgroundView = UIView()
        
        self.textLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.bold)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setAction(_ action: PropertyAction, propertiesViewController: PropertiesViewController) {
        self.textLabel?.text = action.name
        self.imageView?.image = action.icon?.scaled(toSize: CGSize(width: 25, height: 25))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.textLabel?.text = nil
    }
    
    override func applyTheme(_ theme: Theme) {
        self.textLabel?.textColor = theme.barButtonColor
        self.selectedBackgroundView?.backgroundColor = theme.tableCellBackgroundSelectedColor
    }
}
