//
//  String.swift
//  ExSwift
//
//  Created by pNre on 03/06/14.
//  Copyright (c) 2014 pNre. All rights reserved.
//

import UIKit

public extension String {

    /**
        String length
    */
    var length: Int { return self.characters.count }

    /**
        self.capitalizedString shorthand
    */
    var capitalized: String { return capitalizedString }
    
    var capitalizedFirstLetter: String {
        
        if self.characters.count < 1 {
            return self
        }
        
        return self.stringByReplacingCharactersInRange(self.startIndex...self.startIndex, withString: String(self.characters.first!).capitalizedString)
    }

    /**
        Returns the substring in the given range

        - parameter range:
        - returns: Substring in range
    */
    subscript (range: Range<Int>) -> String? {
        if range.startIndex < 0 || range.endIndex > self.length {
            return nil
        }

        let range = startIndex.advancedBy(range.startIndex)..<startIndex.advancedBy(range.endIndex)

        return self[range]
    }

    /**
        Equivalent to at. Takes a list of indexes and returns an Array
        containing the elements at the given indexes in self.

        - parameter firstIndex:
        - parameter secondIndex:
        - parameter restOfIndexes:
        - returns: Charaters at the specified indexes (converted to String)
    */
    subscript (firstIndex: Int, secondIndex: Int, restOfIndexes: Int...) -> [String] {
        return at([firstIndex, secondIndex] + restOfIndexes)
    }

    /**
        Gets the character at the specified index as String.
        If index is negative it is assumed to be relative to the end of the String.

        - parameter index: Position of the character to get
        - returns: Character as String or nil if the index is out of bounds
    */
    subscript (index: Int) -> String? {
        if let char = Array(self.characters).get(index) {
            return String(char)
        }

        return nil
    }

    /**
        Takes a list of indexes and returns an Array containing the elements at the given indexes in self.

        - parameter indexes: Positions of the elements to get
        - returns: Array of characters (as String)
    */
    func at (indexes: Int...) -> [String] {
        return indexes.map { self[$0]! }
    }

    /**
        Takes a list of indexes and returns an Array containing the elements at the given indexes in self.

        - parameter indexes: Positions of the elements to get
        - returns: Array of characters (as String)
    */
    func at (indexes: [Int]) -> [String] {
        return indexes.map { self[$0]! }
    }

    /**
        Returns an array of strings, each of which is a substring of self formed by splitting it on separator.

        - parameter separator: Character used to split the string
        - returns: Array of substrings
    */
    func explode (separator: Character) -> [String] {
      return self.characters.split { $0 == separator }.map { String($0) }
    }

    /**
        Finds any match in self for pattern.

        - parameter pattern: Pattern to match
        - parameter ignoreCase: true for case insensitive matching
        - returns: Matches found (as [NSTextCheckingResult])
    */
    func matches (pattern: String, ignoreCase: Bool = false) throws -> [NSTextCheckingResult]? {

        if let regex = try ExSwift.regex(pattern, ignoreCase: ignoreCase) {
            //  Using map to prevent a possible bug in the compiler
            return regex.matchesInString(self, options: [], range: NSMakeRange(0, length)).map { $0 as NSTextCheckingResult }
        }

        return nil

    }

    /**
    Check is string with this pattern included in string

    - parameter pattern: Pattern to match
    - parameter ignoreCase: true for case insensitive matching
    - returns: true if contains match, otherwise false
    */
    func containsMatch (pattern: String, ignoreCase: Bool = false) throws -> Bool? {
        if let regex = try ExSwift.regex(pattern, ignoreCase: ignoreCase) {
            let range = NSMakeRange(0, self.characters.count)
            return regex.firstMatchInString(self, options: [], range: range) != nil
        }

        return nil
    }

    /**
    Replace all pattern matches with another string
    
    - parameter pattern: Pattern to match
    - parameter replacementString: string to replace matches
    - parameter ignoreCase: true for case insensitive matching
    - returns: true if contains match, otherwise false
    */
    func replaceMatches (pattern: String, withString replacementString: String, ignoreCase: Bool = false) throws -> String? {
        if let regex = try ExSwift.regex(pattern, ignoreCase: ignoreCase) {
            let range = NSMakeRange(0, self.characters.count)
            return regex.stringByReplacingMatchesInString(self, options: [], range: range, withTemplate: replacementString)
        }
        
        return nil
    }
    
    /**
        Inserts a substring at the given index in self.

        - parameter index: Where the new string is inserted
        - parameter string: String to insert
        - returns: String formed from self inserting string at index
    */
    func insert (index: Int, _ string: String) -> String {
        //  Edge cases, prepend and append
        if index > length {
            return self + string
        } else if index < 0 {
            return string + self
        }

        return self[0..<index]! + string + self[index..<length]!
    }

    /**
        Strips the specified characters from the beginning of self.

        - returns: Stripped string
    */
    func trimmedLeft (characterSet set: NSCharacterSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()) -> String {
        if let range = rangeOfCharacterFromSet(set.invertedSet) {
            return self[range.startIndex..<endIndex]
        }

        return ""
    }

    @available(*, unavailable, message="use 'trimmedLeft' instead") func ltrimmed (set: NSCharacterSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()) -> String {
        return trimmedLeft(characterSet: set)
    }

    /**
        Strips the specified characters from the end of self.

        - returns: Stripped string
    */
    func trimmedRight (characterSet set: NSCharacterSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()) -> String {
        if let range = rangeOfCharacterFromSet(set.invertedSet, options: NSStringCompareOptions.BackwardsSearch) {
            return self[startIndex..<range.endIndex]
        }

        return ""
    }

    @available(*, unavailable, message="use 'trimmedRight' instead") func rtrimmed (set: NSCharacterSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()) -> String {
        return trimmedRight(characterSet: set)
    }

    /**
        Strips whitespaces from both the beginning and the end of self.

        - returns: Stripped string
    */
    func trimmed () -> String {
        return trimmedLeft().trimmedRight()
    }

    /**
        Costructs a string using random chars from a given set.

        - parameter length: String length. If < 1, it's randomly selected in the range 0..16
        - parameter charset: Chars to use in the random string
        - returns: Random string
    */
    static func random (len: Int = 0, charset: String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789") -> String {

        var len = len
        if len < 1 {
            len = Int.random(max: 16)
        }

        var result = String()
        let max = charset.length - 1

        len.times {
            result += charset[Int.random(0, max: max)]!
        }

        return result

    }


    /**
        Parses a string containing a double numerical value into an optional double if the string is a well formed number.

        - returns: A double parsed from the string or nil if it cannot be parsed.
    */
    func toDouble() -> Double? {

        let scanner = NSScanner(string: self)
        var double: Double = 0

        if scanner.scanDouble(&double) {
            return double
        }

        return nil

    }

    /**
       Parses a string containing a float numerical value into an optional float if the string is a well formed number.

       - returns: A float parsed from the string or nil if it cannot be parsed.
    */
    func toFloat() -> Float? {

        let scanner = NSScanner(string: self)
        var float: Float = 0

        if scanner.scanFloat(&float) {
            return float
        }

        return nil

    }

    /**
        Parses a string containing a non-negative integer value into an optional UInt if the string is a well formed number.

        - returns: A UInt parsed from the string or nil if it cannot be parsed.
    */
    func toUInt() -> UInt? {
        if let val = Int(self.trimmed()) {
            if val < 0 {
                return nil
            }
            return UInt(val)
        }

        return nil
    }


    /**
      Parses a string containing a boolean value (true or false) into an optional Bool if the string is a well formed.

      - returns: A Bool parsed from the string or nil if it cannot be parsed as a boolean.
    */
    func toBool() -> Bool? {
        let text = self.trimmed().lowercaseString
        if text == "true" || text == "false" || text == "yes" || text == "no" {
            return (text as NSString).boolValue
        }

        return nil
    }

    /**
      Parses a string containing a date into an optional NSDate if the string is a well formed.
      The default format is yyyy-MM-dd, but can be overriden.

      - returns: A NSDate parsed from the string or nil if it cannot be parsed as a date.
    */
    func toDate(format : String? = "yyyy-MM-dd") -> NSDate? {
        let text = self.trimmed().lowercaseString
        let dateFmt = NSDateFormatter()
        dateFmt.timeZone = NSTimeZone.defaultTimeZone()
        if let fmt = format {
            dateFmt.dateFormat = fmt
        }
        return dateFmt.dateFromString(text)
    }

    /**
      Parses a string containing a date and time into an optional NSDate if the string is a well formed.
      The default format is yyyy-MM-dd hh-mm-ss, but can be overriden.

      - returns: A NSDate parsed from the string or nil if it cannot be parsed as a date.
    */
    func toDateTime(format : String? = "yyyy-MM-dd hh-mm-ss") -> NSDate? {
        return toDate(format)
    }

}

/**
    Repeats the string first n times
*/
public func * (first: String, n: Int) -> String {

    var result = String()

    n.times {
        result += first
    }

    return result

}

//  Pattern matching using a regular expression
public func =~ (string: String, pattern: String) throws -> Bool {

    let regex = try ExSwift.regex(pattern, ignoreCase: false)!
    let matches = regex.numberOfMatchesInString(string, options: [], range: NSMakeRange(0, string.length))

    return matches > 0

}

//  Pattern matching using a regular expression
public func =~ (string: String, regex: NSRegularExpression) -> Bool {

    let matches = regex.numberOfMatchesInString(string, options: [], range: NSMakeRange(0, string.length))

    return matches > 0

}

//  This version also allowes to specify case sentitivity
public func =~ (string: String, options: (pattern: String, ignoreCase: Bool)) throws -> Bool {

    if let matches = try ExSwift.regex(options.pattern, ignoreCase: options.ignoreCase)?.numberOfMatchesInString(string, options: [], range: NSMakeRange(0, string.length)) {
        return matches > 0
    }

    return false

}

//  Match against all the alements in an array of String
public func =~ (strings: [String], pattern: String) throws -> Bool {

    let regex = try ExSwift.regex(pattern, ignoreCase: false)!

    return strings.all { $0 =~ regex }

}

public func =~ (strings: [String], options: (pattern: String, ignoreCase: Bool)) throws -> Bool {

    var lastError: ErrorType?

    let result = strings.all {
        do {
            return try $0 =~ options
        } catch let error {
            lastError = error
            return false
        }
    }
    
    if let error = lastError {
        throw error
    }
    
    return result
    
}

//  Match against any element in an array of String
public func |~ (strings: [String], pattern: String) throws -> Bool {

    let regex = try ExSwift.regex(pattern, ignoreCase: false)!

    return strings.any { $0 =~ regex }

}

public func |~ (strings: [String], options: (pattern: String, ignoreCase: Bool)) throws -> Bool {

    var lastError: ErrorType?
    
    let result = strings.any {
        do {
            return try $0 =~ options
        } catch let error {
            lastError = error
            return false
        }
    }
    
    if let error = lastError {
        throw error
    }
    
    return result

}



//MARK: New


public extension String {
    
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
        return  String(self.characters.prefix(index)) + string + String(self.characters.suffix(self.characters.count-index))
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
        
        for char in self.characters {
            
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
////        let stricterFilter = true;
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
    
    func attributedString(color: UIColor, font: UIFont? = nil, paragraphStyle: NSParagraphStyle? = nil, underlineStyle: NSUnderlineStyle? = nil) -> NSAttributedString {
        
        var attributes: [String: AnyObject] = [NSForegroundColorAttributeName: color]
        
        if (underlineStyle != nil) {
            attributes[NSUnderlineStyleAttributeName] = underlineStyle!.rawValue
        }
        
        if (paragraphStyle != nil) {
            attributes[NSParagraphStyleAttributeName] = paragraphStyle
        }
        
        if (font != nil) {
            attributes[NSFontAttributeName] = font
        }
        
        return NSAttributedString(string: self, attributes: attributes);
    }
    
    func sizeWithFont(font: UIFont, maxWidth: CGFloat = CGFloat.max, maxHeight: CGFloat = CGFloat.max) -> CGSize {
        
        let constraint = CGSize(width: maxWidth, height: maxHeight)
        let frame = self.boundingRectWithSize(constraint, options:[.UsesLineFragmentOrigin , .UsesFontLeading], attributes:[NSFontAttributeName: font], context:nil)
        return CGSizeMake(ceil(frame.size.width), ceil(frame.size.height));
    }
    
    
    func stringByReplacingCharactersAtIndexes(indexes: [Int], string: String) -> String {
    
        let sortedIndexes = indexes.sort().reverse()
        
        var returnString = self
    
        for index in sortedIndexes {
            if (index < returnString.characters.count) {
                let range = startIndex.advancedBy(index)..<startIndex.advancedBy(index+1)
                returnString = returnString.stringByReplacingCharactersInRange(range, withString: string)
            }
        }
        return returnString;
    }
    
    private static var cache = NSCache()
    
    func attributedHTMLStringWithFont(font: UIFont) -> NSAttributedString? {
        
        let string = self.stringByAppendingString("<style>body{font-family: '\(font.fontName)'; font-size:\(font.pointSize)px;}</style>")
        
        if let attString = String.cache.objectForKey(string) as? NSAttributedString {
            return attString
        }
        
        if let data = string.dataUsingEncoding(NSUnicodeStringEncoding) {
            do {
                let attString = try NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding], documentAttributes: nil)
            String.cache.setObject(attString, forKey: string)
                return attString;
            }
            catch {
                    
            }
            
        }
        
        
        return nil;
    }
}




