//
//  SOCollectionHeaderView.swift
//  Source
//
//  Created by Ian McDowell on 8/19/16.
//  Copyright © 2016 Ian McDowell. All rights reserved.
//
import UIKit

public class SOCollectionHeaderView: SOCollectionReusableView {
    public var titleLabel: UILabel

    public override init(frame: CGRect) {
        titleLabel = UILabel()

        super.init(frame: frame)

        self.backgroundColor = nil

        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .semibold)

        addSubview(titleLabel)
        titleLabel.constrainToEdgesOfSuperview(UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func applyTheme(_ theme: Theme) {
        titleLabel.textColor = theme.tableHeaderTextColor
    }
}
