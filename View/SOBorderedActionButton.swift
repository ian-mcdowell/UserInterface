//
//  SORoundedActionButton.swift
//  Source
//
//  Created by Ian McDowell on 8/20/16.
//  Copyright © 2016 Ian McDowell. All rights reserved.
//
import UIKit

public class SORoundedActionButton: UIButton {

    public init() {
        super.init(frame: CGRect.zero)

        setup()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    private func setup() {
        setTitleColor(.white, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: UIFont.Weight.bold)
        
        self.layer.borderWidth = 2

        // Add padding. 5 on top/bottom, 10 on sides
        titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10)
        contentEdgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 20)

        setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
        
        updateBackgroundColor()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = self.frame.size.height / 2
    }

    public var color: UIColor? {
        didSet {
            updateBackgroundColor()
            layer.borderColor = color?.cgColor
        }
    }

    override public var isHighlighted: Bool {
        didSet {
            updateBackgroundColor()
        }
    }
    
    private func updateBackgroundColor() {
        if isHighlighted {
            self.backgroundColor = nil
        } else {
            self.backgroundColor = color
        }
    }
}
