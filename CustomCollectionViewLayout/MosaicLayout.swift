//
//  MosaicLayout.swift
//  CustomCollectionViewLayout
//
//  Created by Fernando Cardenas on 05.09.18.
//  Copyright © 2018 Fernando Cardenas. All rights reserved.
//

import UIKit

class MosaicLayout: UICollectionViewLayout {

    fileprivate var numberOfColumns = 3
    fileprivate var cellPading: CGFloat = 6.0

    fileprivate var cachedAttributes = [UICollectionViewLayoutAttributes]()

    fileprivate var contentHeight: CGFloat = 0.0

    fileprivate var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }

    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }

    override func prepare() {

        super.prepare()

        cachedAttributes.removeAll()
        //Reset cached info
        //for every item
        // - Prepare attributes
        // - Store attributes in cachedAttributes array
        // - union contentBounds with attributes.frame
//        createAttibutes()

        createAttributes()
    }

    // This method creates a bug at the end of the views, still needs further improvements
    func createAttributes() {
        guard let cv = collectionView else { return }

        let availableWidth = contentWidth

        let minColumnWidth: CGFloat = 100.0
        let maxNumColumns = Int(availableWidth / minColumnWidth)

        let columnWidth = (availableWidth / CGFloat(maxNumColumns)).rounded(.down)
        var xOffset = [CGFloat]()

        for column in 0 ..< maxNumColumns {
            xOffset.append(CGFloat(column) * columnWidth)
        }
        var column = 0
        var yOffset = [CGFloat](repeating: 0, count: maxNumColumns)

        for item in 0 ..< cv.numberOfItems(inSection: 0) {

            let indexPath = IndexPath(item: item, section: 0)

            let photoHeight: CGFloat = CGFloat.random(in: 100...300)

            let height = cellPading * 2 + photoHeight
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
            let insetFrame = frame.insetBy(dx: cellPading, dy: cellPading)

            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cachedAttributes.append(attributes)

            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height

            column = column < (maxNumColumns - 1) ? (column + 1) : 0
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {

        // Used if the the elements are sorted if cachedAttributes by e.g maxY

//        // Find any cell that sits within the query rect
//
//        guard let firstMatchIndex = binarySearch(range: 0..<cachedAttributes.endIndex, rect: rect) else { return attributesArray }
//
//        // Starting from our match, loop up and down through the array until we´ve
//        // added all attributes with frames within our query rect
//
//        for attributes in cachedAttributes [..<firstMatchIndex].reversed() {
//            guard attributes.frame.maxY >= rect.minY else { break }
//            attributesArray.append(attributes)
//        }
//
//        for attributes in cachedAttributes[firstMatchIndex...] {
//            guard attributes.frame.minY <= rect.maxY else { break }
//            attributesArray.append(attributes)
//        }

        let attributesArray = cachedAttributes.filter { $0.frame.intersects(rect) }

        return attributesArray
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let cv = collectionView else { return false }
        return !newBounds.size.equalTo(cv.bounds.size)
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cachedAttributes[indexPath.item]
    }

    func binarySearch(range: Range<Int>, rect: CGRect) -> Int? {
        if range.lowerBound >= range.upperBound {
            // If we get here, then the search key is not present in the array.
            return nil

        } else {
            // Calculate where to split the array.
            let midIndex = range.lowerBound + (range.upperBound - range.lowerBound) / 2

            // Is the search key in the left half?
            if cachedAttributes[midIndex].frame.maxY < rect.minY {
                // Is the search key in the right half?
                return binarySearch(range: midIndex + 1 ..< range.upperBound, rect: rect)
            } else if cachedAttributes[midIndex].frame.minY > rect.maxY {
                // If we get here, then we've found the search key!
                return binarySearch(range: range.lowerBound ..< midIndex, rect: rect)
            } else {
                print("Midindex \(midIndex)")
                return midIndex
            }
        }
    }
}
