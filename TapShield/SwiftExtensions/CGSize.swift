//
//  CGSize.swift
//  GPTest
//
//  Created by Adam J Share on 1/5/16.
//  Copyright © 2016 Adam J Share. All rights reserved.
//

import Foundation
import UIKit

extension CGSize {
    
    func aspectRatioForWidth(newWidth: CGFloat) -> CGSize {
        let newHeight = height * newWidth / width
        return CGSizeMake(ceil(newWidth), ceil(newHeight))
    }
    
    func aspectRatioForHeight(newHeight: CGFloat) -> CGSize {
        let newWidth = width * newHeight / height
        return CGSizeMake(ceil(newWidth), ceil(newHeight))
    }
    
}
