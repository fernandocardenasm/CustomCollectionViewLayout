//
//  BaseCollectionViewLayout.swift
//  CustomCollectionViewLayout
//
//  Created by Fernando Cardenas on 20.09.18.
//  Copyright © 2018 Fernando Cardenas. All rights reserved.
//

import UIKit

class OCTBaseCollectionViewLayout: UICollectionViewLayout {
    private var layoutMap = [IndexPath : UICollectionViewLayoutAttributes]()
    private var columnsYoffset = [CGFloat]()
    private var contentSize = CGSize.zero

    private(set) var totalItemsInSection = 0

    var totalColumns = 0
    var interItemsSpacing: CGFloat = 8

    //MARK: getters
    var contentInsets: UIEdgeInsets {
        guard let cv = collectionView else { return UIEdgeInsets.zero }
        return cv.contentInset
    }

    override var collectionViewContentSize: CGSize {
        return contentSize
    }

    //MARK: Override methods
    override func prepare() {
        
        layoutMap.removeAll()

        guard let cv = collectionView else { return }
        columnsYoffset = Array(repeating: 0, count: totalColumns)

        totalItemsInSection = cv.numberOfItems(inSection: 0)

        if totalItemsInSection > 0 && totalColumns > 0 {
            self.calculateItemsSize()

            var itemIndex = 0
            var contentSizeHeight: CGFloat = 0

            while itemIndex < totalItemsInSection {
                let indexPath = IndexPath(item: itemIndex, section: 0)
                let columnIndex = self.columnIndexForItemAt(indexPath: indexPath)

                let attributeRect = calculateItemFrame(indexPath: indexPath, columnIndex: columnIndex, columnYoffset: columnsYoffset[columnIndex])
                let targetLayoutAttributes = UICollectionViewLayoutAttributes.init(forCellWith: indexPath)
                targetLayoutAttributes.frame = attributeRect

                contentSizeHeight = max(attributeRect.maxY, contentSizeHeight)
                columnsYoffset[columnIndex] = attributeRect.maxY + interItemsSpacing
                layoutMap[indexPath] = targetLayoutAttributes

                itemIndex += 1
            }
            contentSize = CGSize(width: cv.bounds.width - contentInsets.left - contentInsets.right,
                                 height: contentSizeHeight)
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributesArray = [UICollectionViewLayoutAttributes]()

        for (_, layoutAttributes) in layoutMap {
            if rect.intersects(layoutAttributes.frame) {
                layoutAttributesArray.append(layoutAttributes)
            }
        }

        return layoutAttributesArray
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutMap[indexPath]
    }

    //MARK: Abstract methods
    func columnIndexForItemAt(indexPath: IndexPath) -> Int {
        return indexPath.item % totalColumns
    }
    func calculateItemFrame(indexPath: IndexPath, columnIndex: Int, columnYoffset: CGFloat) -> CGRect {
        return CGRect.zero
    }
    func calculateItemsSize() {}
}
