//
//  OCTGalleryLayout.swift
//  CustomCollectionViewLayout
//
//  Created by Fernando Cardenas on 20.09.18.
//  Copyright © 2018 Fernando Cardenas. All rights reserved.
//

import UIKit

private let kReducedHeightColumnIndex = 1
private let kItemHeightAspect: CGFloat  = 2

class OCTGalleryLayout_v1: OCTBaseCollectionViewLayout {
    private var itemSize = CGSize.zero
    private var columnsXoffset = [CGFloat]()

    init(numberOfColumns: Int = 3) {
        super.init()
        self.totalColumns = numberOfColumns
    }

    //MARK: Init
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: Override getters
    override var description: String {
        return "Layout v1"
    }

    //MARK: Override Abstract methods
    override func columnIndexForItemAt(indexPath: IndexPath) -> Int {
        //If last item is single in row, we move it to reduced column, to make it looks nice
        let columnIndex = indexPath.item % totalColumns
        return self.isLastItemSingleInRow(indexPath) ? kReducedHeightColumnIndex : columnIndex
    }

    override func calculateItemFrame(indexPath: IndexPath, columnIndex: Int, columnYoffset: CGFloat) -> CGRect {
        let rowIndex = indexPath.item / totalColumns
        let halfItemHeight = (itemSize.height - interItemsSpacing) / 2

        //Resolving Item height
        var itemHeight = itemSize.height

        // By our logic, first and last items in reduced height column have height divided by 2.
        if (rowIndex == 0 && columnIndex == kReducedHeightColumnIndex) || self.isLastItemSingleInRow(indexPath) {
            itemHeight = halfItemHeight
        }

        return CGRect(x: columnsXoffset[columnIndex], y: columnYoffset, width: itemSize.width, height: itemHeight)
    }

    override func calculateItemsSize() {
        guard let cv = collectionView else { return }
        let contentWidthWithoutIndents = cv.bounds.width - contentInsets.left - contentInsets.right
        let itemWidth = (contentWidthWithoutIndents - (CGFloat(totalColumns) - 1) * interItemsSpacing) / CGFloat(totalColumns)
        let itemHeight = itemWidth * kItemHeightAspect

        itemSize = CGSize(width: itemWidth, height: itemHeight)

        // Calculating offsets by X for each column
        columnsXoffset = []

        for columnIndex in 0...(totalColumns - 1) {
            columnsXoffset.append(CGFloat(columnIndex) * (itemSize.width + interItemsSpacing))
        }
    }

    //MARK: Private methods
    private func isLastItemSingleInRow(_ indexPath: IndexPath) -> Bool {
        return indexPath.item == (totalItemsInSection - 1) && indexPath.item % totalColumns == 0
    }
}
