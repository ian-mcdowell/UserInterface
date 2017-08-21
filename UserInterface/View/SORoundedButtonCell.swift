//
//  SORoundedButtonCell.swift
//  Source
//
//  Created by Ian McDowell on 8/19/16.
//  Copyright © 2016 Ian McDowell. All rights reserved.
//

/// Delegate for `SORoundedButtonCell`.
public protocol SORoundedButtonCellDelegate: class {
    func didLongPressButtonCell(_ cell: SORoundedButtonCell, _ item: Any)
}

/// A rounded button `UICollectionViewCell` base class.
/// Do not use this class, always subclass.
open class SORoundedButtonCell: SOCollectionViewCell {

    public let label = UILabel()
    public let imageView = UIImageView()
    fileprivate var roundedView: UIView? {
        didSet {
            if let roundedView = roundedView {
                roundedView.layer.cornerRadius = 5
                roundedView.layer.masksToBounds = false

                roundedView.layer.shadowColor = UIColor.black.cgColor
                roundedView.layer.shadowRadius = 5
                roundedView.layer.shadowOffset = CGSize.zero
                roundedView.layer.shadowOpacity = 0.1

                // Adding corner radius and shadow causes major scrolling perf hit.
                // Rasterizing the layer helps a ton
                roundedView.layer.shouldRasterize = true
                roundedView.layer.rasterizationScale = UIScreen.main.scale
            }
        }
    }

    public var item: Any?
    public weak var delegate: SORoundedButtonCellDelegate?

    private var averageColor: UIColor? {
        didSet {
            if oldValue != averageColor {
                self.updateSelection()
            }
        }
    }

    open override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.2, animations: {
                self.updateSelection()
            })
        }
    }

    open override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.2, animations: {
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

    open override func applyTheme(_ theme: Theme) {
        super.applyTheme(theme)

        self.averageColor = theme.tableCellBackgroundColor
        self.label.textColor = theme.tableCellTextColor
        self.imageView.tintColor = theme.tableCellTextColor

        switch theme.style {
        case .light:
            roundedView?.layer.shadowOpacity = 0.1
            break
        case .dark:
            roundedView?.layer.shadowOpacity = 0.05
            break
        }
    }

    open func setup() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .center

        label.translatesAutoresizingMaskIntoConstraints = false

        label.adjustsFontSizeToFitWidth = true

        self.roundedView = self.contentView

        self.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(SORoundedButtonCell.didLongPress)))
    }

    public func setImage(_ image: UIImage?) {
        imageView.image = image
        setImageViewContentModeBasedOnImage()
    }

    public func setImageViewContentModeBasedOnImage() {
        imageView.contentMode = .scaleAspectFit
    }

    open override func prepareForReuse() {
        super.prepareForReuse()

        imageView.image = nil
        label.text = nil
        item = nil
    }

    open func updateSelection() {
        if self.isSelected || self.isHighlighted {
            self.roundedView?.backgroundColor = self.averageColor?.withAlphaComponent(0.7)
            self.roundedView?.tintColor = UIColor(white: 20 / 255, alpha: 1)
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } else {
            self.roundedView?.backgroundColor = self.averageColor?.withAlphaComponent(0.9)
            self.roundedView?.tintColor = UIColor(white: 0 / 255, alpha: 1)
            self.transform = CGAffineTransform.identity
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        self.isSelected = false

        setImageViewContentModeBasedOnImage()
    }

    func didLongPress() {
        if let item = self.item {
            self.delegate?.didLongPressButtonCell(self, item)
        }
    }
}

/// A special `SORoundedButtonCell` with an image in the center and text below the rounded square.
public class SORoundedSquareImageButtonCell: SORoundedButtonCell {

    private let subtitleLabel = UILabel()
    private var subtitleHeight: NSLayoutConstraint!

    open override func setup() {

        super.setup()

        let roundedView = UIView()
        roundedView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(roundedView)

        roundedView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        roundedView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        roundedView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        roundedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30).isActive = true

        imageView.translatesAutoresizingMaskIntoConstraints = false
        roundedView.addSubview(imageView)
        imageView.constrainToEdgesOfSuperview()

        label.textAlignment = .center
        label.numberOfLines = 0

        contentView.addSubview(label)
        label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        label.topAnchor.constraint(equalTo: imageView.bottomAnchor).isActive = true

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular)
        subtitleLabel.adjustsFontSizeToFitWidth = true
        subtitleLabel.textColor = .white
        subtitleLabel.textAlignment = .center

        contentView.addSubview(subtitleLabel)
        subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        subtitleLabel.topAnchor.constraint(equalTo: label.bottomAnchor).isActive = true
        subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        subtitleHeight = subtitleLabel.heightAnchor.constraint(equalToConstant: 0)
        subtitleHeight.isActive = true

        self.roundedView = roundedView
    }

    public var subtitle: String? {
        didSet {
            subtitleLabel.text = subtitle

            if subtitle != nil {
                subtitleHeight.constant = 13
            } else {
                subtitleHeight.constant = 0
            }
        }
    }

    public override func applyTheme(_ theme: Theme) {
        super.applyTheme(theme)

        // Make the text colors always white
        label.textColor = .white
        subtitleLabel.textColor = .white
    }

    public override func setImageViewContentModeBasedOnImage() {
        let width = imageView.frame.size.width
        let height = imageView.frame.size.height

        if width == 0 || height == 0 {
            return
        }
        if let i = imageView.image {
            if i.size.width > width || i.size.height > height {
                imageView.contentMode = .scaleAspectFit
            } else {
                imageView.contentMode = .center
            }
        }
    }
}
