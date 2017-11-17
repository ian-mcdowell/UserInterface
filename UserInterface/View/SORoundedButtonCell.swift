//
//  SORoundedButtonCell.swift
//  Source
//
//  Created by Ian McDowell on 8/19/16.
//  Copyright © 2016 Ian McDowell. All rights reserved.
//
import UIKit

/// A rounded button `UICollectionViewCell` base class.
/// Do not use this class, always subclass.
open class SORoundedButtonCell: SOCollectionViewCell {

    public let label = UILabel()
    public let imageView = UIImageView()
    public var roundedView: UIView {
        return contentView
    }

    private var roundedViewBackgroundColor: UIColor? {
        didSet {
            if oldValue != roundedViewBackgroundColor {
                self.updateSelection()
            }
        }
    }

    open override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.1, animations: {
                self.updateSelection()
            })
        }
    }

    open override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.1, animations: {
                self.updateSelection()
            })
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.isSelected = false
        
        roundedView.layer.cornerRadius = 5
        roundedView.layer.masksToBounds = false
        roundedView.clipsToBounds = true
        
        roundedView.layer.shadowColor = UIColor.black.cgColor
        roundedView.layer.shadowRadius = 5
        roundedView.layer.shadowOffset = CGSize.zero
        roundedView.layer.shadowOpacity = 0.1
        
        // Adding corner radius and shadow causes major scrolling perf hit.
        // Rasterizing the layer helps a ton
        roundedView.layer.shouldRasterize = true
        roundedView.layer.rasterizationScale = UIScreen.main.scale
    }

    open override func applyTheme(_ theme: Theme) {
        super.applyTheme(theme)

        self.roundedViewBackgroundColor = theme.tableCellBackgroundColor
        self.label.textColor = theme.tableCellTextColor
        self.imageView.tintColor = theme.tableCellTextColor

        switch theme.style {
        case .light:
            roundedView.layer.shadowOpacity = 0.1
            break
        case .dark:
            roundedView.layer.shadowOpacity = 0.05
            break
        }
    }

    open func setup() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit

        label.translatesAutoresizingMaskIntoConstraints = false

        label.adjustsFontSizeToFitWidth = true
    }

    open override func prepareForReuse() {
        super.prepareForReuse()

        imageView.image = nil
        label.text = nil
    }

    open func updateSelection() {
        if self.isSelected || self.isHighlighted {
            self.roundedView.backgroundColor = self.roundedViewBackgroundColor?.withAlphaComponent(0.7)
            self.roundedView.tintColor = UIColor(white: 20 / 255, alpha: 1)
            self.transform = CGAffineTransform(scaleX: 0.98, y: 0.98).translatedBy(x: 0, y: 1)
        } else {
            self.roundedView.backgroundColor = self.roundedViewBackgroundColor?.withAlphaComponent(0.9)
            self.roundedView.tintColor = UIColor(white: 0 / 255, alpha: 1)
            self.transform = CGAffineTransform.identity
        }
    }
}

/// A special `SORoundedButtonCell` with an image in the center and text below the rounded square.
open class SORoundedSquareImageButtonCell: SORoundedButtonCell {

    public let subtitleLabel = UILabel()
    
    // Becomes the rounded view
    private let imageViewContainer = UIView()
    
    public override var roundedView: UIView {
        return imageViewContainer
    }

    open override func setup() {
        super.setup()

        imageViewContainer.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageViewContainer)

        NSLayoutConstraint.activate([
            imageViewContainer.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageViewContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageViewContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageViewContainer.widthAnchor.constraint(equalTo: imageViewContainer.heightAnchor)
        ])

        imageView.translatesAutoresizingMaskIntoConstraints = false
        roundedView.addSubview(imageView)
        imageView.constrainToEdgesOfSuperview()

        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 1
        label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)

        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label.topAnchor.constraint(equalTo: imageViewContainer.bottomAnchor, constant: 5)
        ])

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.9)
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 1
        subtitleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        subtitleLabel.setContentHuggingPriority(.defaultLow, for: .vertical)

        contentView.addSubview(subtitleLabel)
        NSLayoutConstraint.activate([
            subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: label.bottomAnchor),
            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
    }

    open override func applyTheme(_ theme: Theme) {
        super.applyTheme(theme)

        // Make the text colors always white
        label.textColor = .white
        subtitleLabel.textColor = .white
    }

}
