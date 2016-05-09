//
//  UICollectionViewCell.swift
//  Pods
//
//  Created by Adam J Share on 11/9/15.
//
//

import Foundation
import UIKit

public extension UICollectionViewCell {
    
    
    class func registerNibWithCollectionView(collectionView: UICollectionView) {
        collectionView.registerNib(self.nib, forCellWithReuseIdentifier:self.className)
    }
    
    class func registerClassWithCollectionView(collectionView: UICollectionView) {
        collectionView.registerClass(self, forCellWithReuseIdentifier:self.className);
    }
    
    class var cellSize: CGSize {
        return CGSize(width: 50, height: 50)
    }
    
}
    