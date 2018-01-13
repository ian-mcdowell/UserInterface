//
//  SOTableViewCell.swift
//  Source
//
//  Created by Ian McDowell on 11/17/16.
//  Copyright © 2016 Ian McDowell. All rights reserved.
//
import UIKit

/// Themeable UITableViewCell base class.
open class SOTableViewCell: UITableViewCell, Themeable {
    
    private var themeObserver: Any?

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    private func setup() {
        applyCurrentTheme()
        themeObserver = NotificationCenter.default.addObserver(forName: Theme.DidChangeNotification, object: nil, queue: .main, using: { [weak self] _ in self?.applyCurrentTheme() })
    }
    
    deinit {
        if let observer = self.themeObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    open func applyTheme(_ theme: Theme) {
        self.textLabel?.textColor = theme.tableCellTextColor
        self.detailTextLabel?.textColor = theme.tableCellSecondaryTextColor
        self.imageView?.tintColor = theme.tableCellTextColor
        self.backgroundColor = theme.tableCellBackgroundColor

        self.selectedBackgroundView = UIView()
        self.selectedBackgroundView?.backgroundColor = theme.tableCellBackgroundSelectedColor
    }

}

public class SOTableViewCellText: SOTableViewCell {
    
    public let label = UILabel()
    
    public override var textLabel: UILabel? { fatalError("Do not use textLabel on SOTableViewCellText") }
    public override var detailTextLabel: UILabel? { fatalError("Do not use detailTextLabel on SOTableViewCellText") }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("Can't init a SOTableViewCellText with a nib/storyboard.")
    }
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        self.contentView.addSubview(label)
        label.constrainToEdgesOfSuperview(UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20))
    }
    
    public override func applyTheme(_ theme: Theme) {
        self.backgroundColor = theme.tableCellBackgroundColor
        
        self.selectedBackgroundView = UIView()
        self.selectedBackgroundView?.backgroundColor = theme.tableCellBackgroundSelectedColor
        
        label.textColor = theme.tableCellTextColor
    }
}

public class SOTableViewCellSubtitleRight: SOTableViewCell {
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("Can't init a SOTableViewCellSubtitleRight with a nib/storyboard.")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }
}

public class SOTableViewCellSubtitle: SOTableViewCell {
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("Can't init a SOTableViewCellSubtitle with a nib/storyboard.")
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
}

public class SOTableViewCellTextView: SOTableViewCell {
    
    public let textView: UITextView
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.regular)
        textView.backgroundColor = .clear
        
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(textView)
        textView.constrainToEdgesOfSuperview(UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10))
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func applyTheme(_ theme: Theme) {
        super.applyTheme(theme)
        
        textView.textColor = theme.tableCellTextColor
    }
}

public class SOTableViewCellTextEntry: SOTableViewCell {
    
    public let textField = UITextField()
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        
        guard let textLabel = self.textLabel else {
            return
        }
        self.selectionStyle = .none
        
        textField.textAlignment = .right
        textField.adjustsFontSizeToFitWidth = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: textLabel.trailingAnchor, constant: 20),
            textField.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            textField.topAnchor.constraint(equalTo: textLabel.topAnchor),
            textField.bottomAnchor.constraint(equalTo: textLabel.bottomAnchor)
        ])
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

