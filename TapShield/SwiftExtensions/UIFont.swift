//
//  UIFont.swift
//  Pods
//
//  Created by Adam J Share on 11/9/15.
//
//

import Foundation
import UIKit

public extension UIFont {
    
    class var FuturaPTHeavy: String { return "FuturaPT-Heavy" }
    class var AvenirNextMedium: String { return "AvenirNext-Medium" }
    class var AvenirNextRegular: String { return "AvenirNext-Regular" }
    
    convenience init(futuraHeavySize: CGFloat) {
        self.init(name: UIFont.FuturaPTHeavy, size: futuraHeavySize)!
    }
    
    convenience init(avenirNextMediumSize: CGFloat) {
        self.init(name: UIFont.AvenirNextMedium, size: avenirNextMediumSize)!
    }
    
    convenience init(avenirNextRegularSize: CGFloat) {
        self.init(name: UIFont.AvenirNextRegular, size: avenirNextRegularSize)!
    }
}