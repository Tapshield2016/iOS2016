//
//  UITextView.swift
//  Pods
//
//  Created by Adam J Share on 11/5/15.
//
//

import UIKit

public extension UITextView {
    
    var contentWithAttachments: [String] {
        
        var array: [String] = []
        
        self.textStorage.enumerateAttributesInRange(NSMakeRange(0, self.attributedText.length), options: NSAttributedStringEnumerationOptions.LongestEffectiveRangeNotRequired) { (attrs, range, stop) -> Void in
            
            if let attachment = attrs[NSAttachmentAttributeName] as? NSTextAttachment {
                
                if let fileName = attachment.fileWrapper?.filename {
                    array.append(fileName)
                }
            }
            else {
                let string = self.attributedText.string
                array.append(string.substringWithRange(range.toRange(string)))
            }
        }
        
        return array;
    }
    
    func scrollToBottom() {
        
        if (self.text.length > 0) {
            let bottom = NSMakeRange(self.text.length - 1, 1);
            self.scrollRangeToVisible(bottom)
        }
    }
}