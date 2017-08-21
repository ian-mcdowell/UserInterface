//
//  SOAlertView.swift
//  UserInterface
//
//  Created by Ian McDowell on 2/28/17.
//  Copyright © 2017 Ian McDowell. All rights reserved.
//

import Foundation

/// A full-screen alert view with an action button.
open class SOAlertView: UIView {
    
    public let imageView: UIImageView
    public let label: UILabel
    public let actionButton: UIButton
    
    public init() {
        label = UILabel()
        actionButton = UIButton(type: .system)
        imageView = UIImageView()
        
        super.init(frame: .zero)
        
        self.backgroundColor = Theme.current.backgroundColor
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = image?.scaled(toHeight: 50)
        imageView.tintColor = Theme.current.emptyTextColor
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.baselineAdjustment = .alignCenters
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = Theme.current.emptyTextColor
        
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.addTarget(self, action: #selector(SOAlertView.actionButtonTapped), for: .touchUpInside)
        actionButton.tintColor = Theme.current.barButtonColor
        
        self.addSubview(imageView)
        self.addSubview(label)
        self.addSubview(actionButton)
        
        imageView.topAnchor.constraint(greaterThanOrEqualTo: self.topAnchor, constant: 40).isActive = true
        imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -40).isActive = true
        
        label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 40).isActive = true
        label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -40).isActive = true
        label.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        actionButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 40).isActive = true
        actionButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        self.setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open var image: UIImage? {
        return nil
    }
    
    open func setup() {
        
    }
    
    open func actionButtonTapped() {
        
    }
    
}
