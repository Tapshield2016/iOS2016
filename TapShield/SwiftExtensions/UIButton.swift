//
//  UIButton.swift
//  Pods
//
//  Created by Adam J Share on 11/6/15.
//
//

import Foundation
import UIKit

public extension UIButton {
    
    @IBInspectable var backgroundImageColor: UIColor? {
        
        set {
            self.setBackgroundImageColor(newValue)
        }
        get {
            return self.backgroundImageForState(.Normal)?.averageColor
        }
    }
    
    func setBackgroundImageColor(color: UIColor?, forState: UIControlState = .Normal) {
        self.setBackgroundImage(UIImage(color: color), forState: forState)
    }
    
    @IBInspectable var backgroundHighlightedImageColor: UIColor? {
        
        set {
            self.setBackgroundImageColor(newValue, forState: .Highlighted)
        }
        get {
            return self.backgroundImageForState(.Highlighted)?.averageColor
        }
    }
    
    
    @IBInspectable var backgroundSelectedImageColor: UIColor? {
        
        set {
            self.setBackgroundImageColor(newValue, forState: .Selected)
        }
        get {
            return self.backgroundImageForState(.Selected)?.averageColor
        }
    }
    
    
}