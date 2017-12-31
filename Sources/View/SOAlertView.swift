//
//  SOAlertView.swift
//  UserInterface
//
//  Created by Ian McDowell on 2/28/17.
//  Copyright © 2017 Ian McDowell. All rights reserved.
//
import UIKit

/// A full-screen alert view with an action button.
open class SOAlertView: UIView, Themeable {
    
    public let imageView: UIImageView
    public let label: UILabel
    public let actionButton: UIButton
    
    private let actionBlock: (() -> Void)?
    
    public init(image: UIImage?, text: String, actionButtonText: String?, action: (() -> Void)?) {
        label = UILabel()
        imageView = UIImageView()
        actionButton = UIButton(type: .system)
        actionBlock = action
        
        super.init(frame: .zero)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = image?.scaled(toHeight: 50)
        
        label.text = text
        label.translatesAutoresizingMaskIntoConstraints = false
        label.baselineAdjustment = .alignCenters
        label.textAlignment = .center
        label.numberOfLines = 0
        
        self.addSubview(imageView)
        self.addSubview(label)
        
        if let actionButtonText = actionButtonText {
            actionButton.translatesAutoresizingMaskIntoConstraints = false
            actionButton.setTitle(actionButtonText, for: .normal)
            actionButton.addTarget(self, action: #selector(SOAlertView.actionButtonTapped), for: .touchUpInside)
            self.addSubview(actionButton)
            actionButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 40).isActive = true
            actionButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        }
        
        imageView.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor, constant: 40).isActive = true
        imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -40).isActive = true
        
        label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 40).isActive = true
        label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -40).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true

        self.applyCurrentTheme()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc open func actionButtonTapped() {
        actionBlock?()
    }
    
    public func applyTheme(_ theme: Theme) {
        self.backgroundColor = theme.backgroundColor
        imageView.tintColor = theme.emptyTextColor
        label.textColor = theme.emptyTextColor
        actionButton.tintColor = theme.barButtonColor
    }
    
}
