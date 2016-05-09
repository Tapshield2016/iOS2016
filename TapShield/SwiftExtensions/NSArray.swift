//
//  NSArray.swift
//  ExSwift
//
//  Created by pNre on 10/06/14.
//  Copyright (c) 2014 pNre. All rights reserved.
//

import Foundation

public extension NSArray {

    /**
        Converts an NSArray object to an OutType[] array containing the items in the NSArray of type OutType.
        
        - returns: Array of Swift objects
    */
    func cast <OutType> () -> [OutType] {
        var result = [OutType]()
        
        for item : AnyObject in self {
            result += Ex.bridgeObjCObject(item) as [OutType]
        }
        
        return result
    }

    /**
        Flattens a multidimensional NSArray to an OutType[] array 
        containing the items in the NSArray that can be bridged from their ObjC type to OutType.
    
        - returns: Flattened array
    */
    func flatten <OutType> () -> [OutType] {
        var result = [OutType]()
        let mirror = Mirror(reflecting: self)
        if let mirrorChildrenCollection = AnyRandomAccessCollection(mirror.children) {
            for (_, value) in mirrorChildrenCollection {
                result += Ex.bridgeObjCObject(value) as [OutType]
            }
        }

        return result
    }
    
    /**
        Flattens a multidimensional NSArray to a [AnyObject].
    
        - returns: Flattened array
    */
    func flattenAny () -> [AnyObject] {
        var result = [AnyObject]()
        
        for item in self {
            if let array = item as? NSArray {
                result += array.flattenAny()
            } else {
                result.append(item)
            }
        }
        
        return result
    }
}

public extension NSArray {
    
    func flattenedArrayForKey(key: String) -> [AnyObject] {
        
        var result = [AnyObject]()
        
        for item in self {
            if let array = item as? NSArray {
                result += array.flattenedArrayForKey(key)
            } else if item.respondsToSelector(NSSelectorFromString(key)) {
                if let object = item.valueForKey(key) {
                    result.append(object)
                }
            }
        }
        
        return result
    }
    
    func objectEqualToObject(object: AnyObject) -> AnyObject? {
    
        if self.containsObject(object) {
            return self.objectAtIndex(self.indexOfObject(object))
        }
        return nil
    }
    
    func arrayByUnionArray(otherArray: [AnyObject], sortDescriptors: [NSSortDescriptor]? = nil) -> [AnyObject] {
        
        let result = self.mutableCopy()
        
        for value in otherArray {
            if !result.containsObject(value) {
                result.addObject(value)
            }
        }
        
        if let sortDescriptors = sortDescriptors {
            result.sortUsingDescriptors(sortDescriptors)
        }
        return result as! [AnyObject]
    }

    func objectsOfClass(aClass: AnyClass) -> [AnyObject] {
        
        return self.filter({ $0.isKindOfClass(aClass) })
    }
}
