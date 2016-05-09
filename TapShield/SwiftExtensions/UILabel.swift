//
//  UILabel.swift
//  Pods
//
//  Created by Adam J Share on 11/9/15.
//
//

import UIKit

public extension UILabel {
    
    dynamic var substituteFontName: String {
        set {
            let familyName = self.font.familyName;
            if familyName.containsString(UIFont.systemFontOfSize(10).familyName) {
                self.font = UIFont(name: newValue, size:self.font.pointSize)
            }
        }

        get {
            return self.font.fontName
        }
    }
    
    
    var htmlText: String? {
        
        set {
            self.attributedText = newValue?.attributedHTMLStringWithFont(self.font)
        }
        
        get {
            return self.text
        }
    }
}