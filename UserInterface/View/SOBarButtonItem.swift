//
//  SOBarButtonItem.swift
//  Source
//
//  Created by Ian McDowell on 11/19/16.
//  Copyright © 2016 Ian McDowell. All rights reserved.
//
import UIKit

public class SOBarButtonItem: UIBarButtonItem {

    private var button: UIButton?

    /// Intializer to create a UIBarButtonItem with both a title and image adjacent to each other.
    ///
    /// - Parameters:
    ///   - title: button text
    ///   - image: button image to the left of the text
    ///   - style: style of the button
    ///   - target: the recipient of the action
    ///   - action: selector to be called when tapped
    public convenience init(title: String, image: UIImage, style: UIBarButtonItemStyle, target: AnyObject?, action: Selector?) {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setImage(image, for: .normal)

        // Set UIButton title font size to be the same as the UIBarButtonItem font size
        button.titleLabel?.font = (style == UIBarButtonItemStyle.done) ? UIFont.boldSystemFont(ofSize: UIFont.labelFontSize) : UIFont.systemFont(ofSize: UIFont.labelFontSize)

        let textImageSpacing: CGFloat = 5
        let leftRightSpacing: CGFloat = 5

        // Add spacing between image and text, spacing on left and right.

        // If I were to just add left padding to the titleEdgeInsets, the
        // width of the titleLabel would shrink. This shrinking is stopped
        // by adding the same negative padding to the right. Effectively
        // moving the titleLabel to the right without resizing.

        button.titleEdgeInsets = UIEdgeInsets(
            top: 0,
            left: textImageSpacing,
            bottom: 0,
            right: -textImageSpacing
        )
        button.contentEdgeInsets = UIEdgeInsets(
            top: 0,
            left: leftRightSpacing,
            bottom: 0,
            right: leftRightSpacing + textImageSpacing
        )

        button.sizeToFit()
        self.init(customView: button)

        self.button = button
        self.target = target
        self.action = action

        button.addTarget(self, action: #selector(SOBarButtonItem.buttonTapped), for: .touchUpInside)
    }

    // We respond to taps this way in case the target or action changes after init is called.
    @objc func buttonTapped() {
        if let action = self.action {
            _ = self.target?.perform(action)
        }
    }

    public override var title: String? {
        didSet {
            button?.setTitle(title, for: .normal)
            button?.sizeToFit()
        }
    }

    public override var image: UIImage? {
        didSet {
            button?.setImage(image, for: .normal)
            button?.sizeToFit()
        }
    }
}
