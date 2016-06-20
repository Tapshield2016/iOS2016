//
//  UITextField.swift
//  Pods
//
//  Created by Adam J Share on 11/5/15.
//
//

import UIKit

public extension UITextField {
    
    var placeholderColor: UIColor? {
        
        set {
            if let placeholder = self.placeholder, let color = newValue {
                self.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: color])
            }
        }
        get {
            var range = NSMakeRange(0, 1);
            
            if let color = self.attributedPlaceholder?.attribute(NSForegroundColorAttributeName, atIndex: 0, effectiveRange: &range) as? UIColor {
                return color
            }
            return nil
        }
    }
}