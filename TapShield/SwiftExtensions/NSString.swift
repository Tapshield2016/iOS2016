//
//  NSString.swift
//  Pods
//
//  Created by Adam J Share on 12/29/15.
//
//

import Foundation
import UIKit

public extension NSString {
    
    func sizeWithFont(font: UIFont, maxWidth: CGFloat = CGFloat.max, maxHeight: CGFloat = CGFloat.max) -> CGSize {
        
        let constraint = CGSize(width: maxWidth, height: maxHeight)
        let frame = self.boundingRectWithSize(constraint, options:[.UsesLineFragmentOrigin , .UsesFontLeading], attributes:[NSFontAttributeName: font], context:nil)
        return CGSizeMake(ceil(frame.size.width), ceil(frame.size.height))
    }
}



public extension NSString {
    
    var alphaNumeric: String {
        return self.componentsSeparatedByCharactersInSet(NSCharacterSet.alphanumericCharacterSet().invertedSet).joinWithSeparator("")
    }
    
    var decimalDigit: String {
        return self.componentsSeparatedByCharactersInSet(NSCharacterSet.decimalDigitCharacterSet()).joinWithSeparator("")
    }
    
    var numeric: String {
        return self.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "0123456789").invertedSet).joinWithSeparator("")
    }
    
    func stringByRemovingCharactersInString(string: String) -> String {
        let characterSet = NSCharacterSet(charactersInString: string)
        return self.componentsSeparatedByCharactersInSet(characterSet).joinWithSeparator("")
    }
    
    func stringByInsertingString(string:String, index:Int) -> String {
        let asSelf = (self as String)
        return  String(asSelf.characters.prefix(index)) + string + String(asSelf.characters.suffix(asSelf.characters.count-index))
    }
    
    var camelCase: String {
        
        let components = self.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: "._- /,"))
        
        var camelCase: String!
        
        for component in components {
            
            if camelCase == nil {
                camelCase = component
                continue
            }
            
            camelCase = camelCase + component.capitalizedString
        }
        
        return camelCase
    }
    
    var camelCaseCapitalized: String {
        
        return self.capitalizedString.camelCase
    }
    
    var spacedAtCapitalCharacter: String {
        
        var constructedCharacters: [Character] = []
        
        for char in (self as String).characters {
            
            if constructedCharacters.count == 0 || !char.isUpper {
                constructedCharacters.append(char)
            }
            else if char.isUpper {
                constructedCharacters += [" ", char]
            }
        }
        
        return String(constructedCharacters)
    }
    
    var snakeCase: String {
        
        return self.spacedAtCapitalCharacter.lowercaseString.stringByReplacingOccurrencesOfString(" ", withString: "_")
    }
    
    //    var isValidEmail: String {
    //
    ////        let stricterFilter = true
    ////        let stricterFilterString = "[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}"
    ////        let laxString = ".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*"
    //        let emailRegex = "[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}"
    //
    //        var emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
    //        return emailTest.evaluateWithObject(self)
    //    }
    
    func stringByRemovingCharactersInSet(set: NSCharacterSet) -> String {
        return self.componentsSeparatedByCharactersInSet(set).joinWithSeparator("")
    }
    
    var isAlphaNumeric: Bool {
        return self.alphaNumeric == self
    }
    
    var isNumeric: Bool {
        return self.numeric == self
    }
    
    func attributedString(color: UIColor, underlineStyle: NSUnderlineStyle? = nil) -> NSAttributedString {
        
        var attributes: [String: AnyObject] = [NSForegroundColorAttributeName: color]
        
        if (underlineStyle != nil) {
            attributes[NSUnderlineStyleAttributeName] = underlineStyle!.rawValue
        }
        
        return NSAttributedString(string: (self as String), attributes: attributes)
    }
    
    
    func stringByReplacingCharactersAtIndexes(indexes: [Int], string: String) -> String {
        return (self as String).stringByReplacingCharactersAtIndexes(indexes, string: string)
    }
    
    private static var cache = NSCache()
    
    func attributedHTMLStringWithFont(font: UIFont) -> NSAttributedString? {
        
        let string = self.stringByAppendingString("<style>body{font-family: '\(font.fontName)' font-size:\(font.pointSize)px}</style>")
        
        if let attString = String.cache.objectForKey(string) as? NSAttributedString {
            return attString
        }
        
        if let data = string.dataUsingEncoding(NSUnicodeStringEncoding) {
            do {
                let attString = try NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                    NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding], documentAttributes: nil)
                String.cache.setObject(attString, forKey: string)
                return attString
            }
            catch {
                
            }
            
        }
        
        
        return nil
    }
    
    var capitalizedFirstLetter: String {
        
        let asString = self as String
        
        if asString.characters.count < 1 {
            return asString
        }
        
        return asString.stringByReplacingCharactersInRange(asString.startIndex...asString.startIndex, withString: String(asString.characters.first!).capitalizedString)
    }
    
    var formattedPhoneNumber: String {
        
        var numeric = self.numeric
        
        numeric = numeric.insert(0, "(")
        
        if numeric.characters.count > 3 {
            numeric = numeric.insert(3, ")")
        }
        if numeric.characters.count > 6 {
            numeric = numeric.insert(6, "-")
        }
        
        return numeric
    }
}