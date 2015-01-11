//
//  FlowWithHeaderAndSidebar.swift
//  TerpScheduler
//
//  Created by Ben Hall on 1/11/15.
//  Copyright (c) 2015 Tampa Preparatory School. All rights reserved.
//

import UIKit

class FlowWithHeaderAndSidebar: UICollectionViewFlowLayout {
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        var attributesInView = super.layoutAttributesForElementsInRect(rect)
        let cv = self.collectionView!
        let offset = cv.contentOffset
        var missingSections = NSMutableIndexSet()
        for layoutAttributes in attributesInView! {
            if let attributes = layoutAttributes as? UICollectionViewLayoutAttributes {
                if attributes.representedElementCategory == UICollectionElementCategory.Cell {
                    missingSections.addIndex(attributes.indexPath.section)
                }
            }
        }
        for layoutAttributes in attributesInView! {
            if let attributes = layoutAttributes as? UICollectionViewLayoutAttributes {
                if attributes.representedElementKind == UICollectionElementKindSectionHeader {
                    missingSections.removeIndex(attributes.indexPath.section)
                }
            }
        }
        
        missingSections.enumerateIndexesUsingBlock({(indx: Int, stop : UnsafeMutablePointer<ObjCBool>) in
            let indexPath = NSIndexPath(forItem: 0, inSection: indx)
            let layoutAttributes = self.layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: indexPath)
            attributesInView!.append(layoutAttributes)
        })
        
        for layoutAttributes in attributesInView! {
            if let attributes = layoutAttributes as? UICollectionViewLayoutAttributes {
                let section = attributes.indexPath.section
                let numberOfItemsInSection = cv.numberOfItemsInSection(section)
                let firstCellIndexPath = NSIndexPath(forItem: 0, inSection: section)
                let lastCellIndexPath = NSIndexPath(forItem: max(0, numberOfItemsInSection-1), inSection: section)
                
                var firstObjectAttributes : UICollectionViewLayoutAttributes
                var lastObjectAttributes : UICollectionViewLayoutAttributes
            
                if numberOfItemsInSection > 0 {
                    firstObjectAttributes = self.layoutAttributesForItemAtIndexPath(firstCellIndexPath)
                    lastObjectAttributes = self.layoutAttributesForItemAtIndexPath(lastCellIndexPath)
                } else {
                    firstObjectAttributes = self.layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: firstCellIndexPath)
                    lastObjectAttributes = self.layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionFooter, atIndexPath: lastCellIndexPath)
                }
                
                let headerHeight = attributes.frame.height
                var origin = attributes.frame.origin
                origin.y = min( max(offset.y + cv.contentInset.top, firstObjectAttributes.frame.minY - headerHeight), lastObjectAttributes.frame.maxY - headerHeight)
                
                attributes.zIndex = 1024
                attributes.frame = CGRect(origin: origin, size: attributes.size)
            }
            
        }
        return attributesInView
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        return super.layoutAttributesForItemAtIndexPath(indexPath)
    }
    
    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        return super.layoutAttributesForSupplementaryViewOfKind(elementKind, atIndexPath: indexPath)
    }
    
    override func layoutAttributesForDecorationViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        return super.layoutAttributesForDecorationViewOfKind(elementKind, atIndexPath: indexPath)
    }
    
}
