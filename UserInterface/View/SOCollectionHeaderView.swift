//
//  SOCollectionHeaderView.swift
//  Source
//
//  Created by Ian McDowell on 8/19/16.
//  Copyright © 2016 Ian McDowell. All rights reserved.
//

public class SOCollectionHeaderView: UICollectionReusableView {
    public var titleLabel: UILabel

    public override init(frame: CGRect) {
        titleLabel = UILabel()

        super.init(frame: frame)

        self.backgroundColor = nil

        titleLabel.textColor = UIColor.white

        addSubview(titleLabel)
        titleLabel.constrainToEdgesOfSuperview(UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8))
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
