//
//  SOCollectionViewCell.swift
//  Source
//
//  Created by Ian McDowell on 12/28/16.
//  Copyright © 2016 Ian McDowell. All rights reserved.
//

/// Themeable UICollectionViewCell base class.
open class SOCollectionViewCell: UICollectionViewCell, Themeable {

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        applyTheme(Theme.current)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        applyTheme(Theme.current)
    }

    open func applyTheme(_ theme: Theme) {
    }

    open override func prepareForReuse() {
        super.prepareForReuse()

        applyTheme(Theme.current)
    }
}
