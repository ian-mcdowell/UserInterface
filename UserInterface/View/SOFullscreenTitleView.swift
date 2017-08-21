//
//  SOFullscreenTitleView.swift
//  Source
//
//  Created by Ian McDowell on 12/28/16.
//  Copyright © 2016 Ian McDowell. All rights reserved.
//

public class SOFullscreenTitleView: UIView {

    private var textLabel: UILabel
    private var boldTextLabel: UILabel
    private var underline: UIView

    public var textColor: UIColor {
        get {
            return textLabel.textColor
        }
        set {
            textLabel.textColor = newValue
            boldTextLabel.textColor = newValue
        }
    }

    public var borderColor: UIColor? {
        get {
            return underline.backgroundColor
        }
        set {
            underline.backgroundColor = borderColor
        }
    }

    public init(text: String, boldText: String) {
        textLabel = UILabel()
        boldTextLabel = UILabel()
        underline = UIView()
        super.init(frame: .zero)

        textLabel.text = text
        boldTextLabel.text = boldText

        textLabel.font = UIFont.systemFont(ofSize: 40, weight: UIFontWeightLight)
        boldTextLabel.font = UIFont.systemFont(ofSize: 40, weight: UIFontWeightBold)

        textLabel.adjustsFontSizeToFitWidth = true
        boldTextLabel.adjustsFontSizeToFitWidth = true

        textLabel.translatesAutoresizingMaskIntoConstraints = false
        boldTextLabel.translatesAutoresizingMaskIntoConstraints = false
        underline.translatesAutoresizingMaskIntoConstraints = false

        addSubview(textLabel)
        addSubview(boldTextLabel)
        addSubview(underline)

        textLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        textLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        textLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true

        boldTextLabel.leadingAnchor.constraint(equalTo: textLabel.trailingAnchor, constant: text.characters.count > 0 ? 10 : 0).isActive = true
        boldTextLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        boldTextLabel.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        boldTextLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true

        underline.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        underline.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        underline.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        underline.heightAnchor.constraint(equalToConstant: 1).isActive = true

        self.setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
        self.setContentHuggingPriority(UILayoutPriorityRequired, for: .vertical)
        textLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, for: .horizontal)
        boldTextLabel.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, for: .horizontal)
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
