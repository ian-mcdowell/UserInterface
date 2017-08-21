//
//  SOCollectionViewHolderCell.swift
//  Source
//
//  Created by Ian McDowell on 12/23/16.
//  Copyright © 2016 Ian McDowell. All rights reserved.
//

open class SOCollectionViewHolderCell<T: Equatable, V: UICollectionViewCell>: SOCollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    public var flowLayout: SOCollectionViewFlowLayout!
    public var collectionView: UICollectionView!

    open var items: [T] = [T]() {
        didSet {
            if !items.elementsEqual(oldValue) {
                self.collectionView.reloadData()
            }
        }
    }

    public override init(frame: CGRect) {

        flowLayout = SOCollectionViewFlowLayout()
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)

        super.init(frame: frame)

        collectionView.backgroundColor = nil
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false

        collectionView.register(V.self)

        contentView.addSubview(collectionView)
        collectionView.constrainToEdgesOfSuperview()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open override func prepareForReuse() {
        super.prepareForReuse()

        // Clear collectionView
        self.items = [T]()
    }

    // MARK: UICollectionViewDataSource

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(V.self, for: indexPath)

        self.setupCollectionViewCell(cell, withItem: items[indexPath.row])

        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.row]

        self.itemSelected(item, atIndexPath: indexPath)

        collectionView.deselectItem(at: indexPath, animated: true)
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }

    // MARK: Override

    open func setupCollectionViewCell(_ cell: V, withItem item: T) {
    }

    open func itemSelected(_ item: T, atIndexPath indexPath: IndexPath) {
    }
}
