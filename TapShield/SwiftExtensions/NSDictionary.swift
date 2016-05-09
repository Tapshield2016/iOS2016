//
//  NSDictionary.swift
//  Pods
//
//  Created by Adam J Share on 11/10/15.
//
//

import Foundation

public extension NSDictionary {
    
    func nonNullObjectForKey(aKey: String) -> AnyObject? {
        return self.filterNSNull(self.valueForKey(aKey))
    }
    
    func filterNSNull(object: AnyObject?) -> AnyObject? {
        if object is NSNull {
            return nil
        }
        return object
    }
    
    func dictionaryByAddingDictionary(dictionary: [NSObject: AnyObject]) -> [NSObject: AnyObject] {
            let mutable = self.mutableCopy()
            mutable.addEntriesFromDictionary(dictionary)
        return mutable as! [NSObject : AnyObject];
    }
    
    func sortedKeyObjectAtIndex(index: Int) -> AnyObject? {
    
        if index >= self.allKeys.count {
            return nil;
        }
    
        let sortedKeys = self.sortedKeys;
        let key = sortedKeys[index];
        return self.objectForKey(key);
    }
    
    var sortedKeys: [AnyObject] {
        return (self.allKeys as NSArray).sortedArrayUsingSelector(#selector(NSString.compare(_:)))
    }
    
    var sortedKeysDescending: [AnyObject] {
        return self.sortedKeys.reverse()
    }
    
    var allValuesSortedByKey: [AnyObject] {
        return self.objectsForKeys(self.sortedKeys, notFoundMarker: NSNull())
    }
    
    var firstKey: AnyObject? {
        return self.sortedKeys.first
    }
    
    var firstValue: AnyObject? {
        if let firstKey = self.firstKey {
            return self.objectForKey(firstKey)
        }
        return nil
    }
    
    var flattenedValues: [AnyObject] {
        return self.allValues.flattenAny()
    }
    
    func flattenTypedValues<T: AnyObject>() -> [T] {
        
        let flat = self.flattenedValues
        
        if let all = flat as? [T] {
            return all
        }
        
        var matchingType: [T] = []
        
        for value in flat {
            
            print(value)
            if let matched = value as? T {
                matchingType.append(matched)
            }
        }
        
        return matchingType
    }
}