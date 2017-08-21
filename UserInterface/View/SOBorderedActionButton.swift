//
//  SOBorderedActionButton.swift
//  Source
//
//  Created by Ian McDowell on 8/20/16.
//  Copyright © 2016 Ian McDowell. All rights reserved.
//

public class SOBorderedActionButton: UIButton {

    public init() {
        super.init(frame: CGRect.zero)

        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    private func setup() {
        setTitleColor(tintColor, for: UIControlState())
        setTitleColor(UIColor.white, for: .highlighted)

        titleLabel?.font = UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: UIFontWeightRegular)

        layer.cornerRadius = 5
        layer.borderWidth = 1
        layer.borderColor = tintColor.cgColor

        // Add padding. 5 on top/bottom, 10 on sides
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
        contentEdgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 20)

        setContentHuggingPriority(UILayoutPriorityRequired, for: .horizontal)
    }

    override public var tintColor: UIColor! {
        didSet {
            setTitleColor(tintColor, for: UIControlState())
            layer.borderColor = tintColor.cgColor
        }
    }

    override public var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                backgroundColor = tintColor
            } else {
                backgroundColor = nil
            }
        }
    }
}
