//
//  SOCollectionViewFlowLayout.swift
//  Source
//
//  Created by Ian McDowell on 8/20/16.
//  Copyright © 2016 Ian McDowell. All rights reserved.
//
import UIKit

/// A UICollectionViewFlowLayout subclass that invalidates itself on bounds change.
public class SOCollectionViewFlowLayout: UICollectionViewFlowLayout {

    public override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    public var isPagingEnabled: Bool = false

    public override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {

        if !isPagingEnabled {
            return proposedContentOffset
        }


        let collectionViewSize = self.collectionView!.bounds.size
        let proposedContentOffsetCenterX = proposedContentOffset.x + collectionViewSize.width * 0.5

        var proposedRect = self.collectionView!.bounds

        // comment this out if you don't want it to scroll so quickly
        proposedRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionViewSize.width, height: collectionViewSize.height)

        var candidateAttributes: UICollectionViewLayoutAttributes?
        for attributes in self.layoutAttributesForElements(in: proposedRect)! {
            // == Skip comparison with non-cell items (headers and footers) == //
            if attributes.representedElementCategory != .cell {
                continue
            }

            // Get collectionView current scroll position
            let currentOffset = self.collectionView!.contentOffset

            // Don't even bother with items on opposite direction
            // You'll get at least one, or else the fallback got your back
            if (attributes.center.x <= (currentOffset.x + collectionViewSize.width * 0.5) && velocity.x > 0) || (attributes.center.x >= (currentOffset.x + collectionViewSize.width * 0.5) && velocity.x < 0) {
                continue
            }

            // First good item in the loop
            if candidateAttributes == nil {
                candidateAttributes = attributes
                continue
            }

            // Save constants to improve readability
            let lastCenterOffset = candidateAttributes!.center.x - proposedContentOffsetCenterX
            let centerOffset = attributes.center.x - proposedContentOffsetCenterX

            if fabsf(Float(centerOffset)) < fabsf(Float(lastCenterOffset)) {
                candidateAttributes = attributes
            }
        }

        if candidateAttributes != nil {
            // Great, we have a candidate
            return CGPoint(x: candidateAttributes!.center.x - collectionViewSize.width * 0.5, y: proposedContentOffset.y)
        } else {
            // Fallback
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        }
    }
}
