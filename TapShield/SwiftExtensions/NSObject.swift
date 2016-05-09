//
//  NSObject.swift
//  Pods
//
//  Created by Adam J Share on 11/2/15.
//
//

import Foundation
import CoreData


//MARK: All Properties
public extension NSObject {
    
    public var readWriteProperties: [String] {
        
        return self.propertyNames(false, type: .ReadWrite).union(self.swiftReadWriteProperties)
    }
    
    public var allProperties: [String] {
        
        return self.propertyNames(false, type: .All).union(self.swiftProperties)
    }
}


@objc public enum NSObjectPropertyType: Int {
    
    case All, ReadOnly, ReadWrite
}


//MARK: Objc Properties
public extension NSObject {
    
    public func propertyNames(includeNSObject: Bool = false, type: NSObjectPropertyType = .All) -> [String] {
        
        let allProperties = self.dynamicType.propertyNames(includeNSObject)
        var returnProperties = allProperties
        
        for name in allProperties {
            switch type {
            case .All:
                break
            case .ReadOnly:
                let capitalized = name.capitalizedFirstLetter
                let selector = "set\(capitalized):"
                if self.respondsToSelector(Selector(selector)) {
                    returnProperties.remove(name)
                }
                
            case .ReadWrite:
                let capitalized = name.capitalizedFirstLetter
                let selector = "set\(capitalized):"
                if !self.respondsToSelector(Selector(selector)) {
                    returnProperties.remove(name)
                }
            }
        }
        
        return returnProperties
    }
    
    public class func propertyNames(includeNSObject: Bool = false) -> [String] {
        
        var propertyNames: [String] = [];
        
        // retrieve the properties via the class_copyPropertyList function
        var count: UInt32 = 0;
        let myClass: AnyClass = self;
        let properties = class_copyPropertyList(myClass, &count);
        
        // iterate each objc_property_t struct
        for i: UInt32 in 0 ..< count {
            let property = properties[Int(i)];
            
            // retrieve the property name by calling property_getName function
            let cname = property_getName(property);
            
            // covert the c string into a Swift string
            if let name = String.fromCString(cname) {
                
                propertyNames.append(name);
            }
        }
        
        // release objc_property_t structs
        free(properties);
        
        //Get properties of superclass until NSObject
        
        if let superClass = self.superclass() as? NSObject.Type {
            
            if !includeNSObject && superClass === NSObject.self {
                return propertyNames
            }
            propertyNames = propertyNames.union(superClass.propertyNames(includeNSObject))
        }
        
        return propertyNames;
    }
    
    public func classOfProperty(name: String) -> AnyClass? {
        
        if let type = self.propertyType(name) {
            
            var typeClass: AnyClass? = NSClassFromString(type)
            
            if typeClass === NSArray.self || typeClass === NSSet.self || typeClass === NSDictionary.self  {
                typeClass = self.objcPropertyCollectionObjectType(name)
            }
            return typeClass
        }
        
        return nil
    }
    
    public func propertyType(name:String)->String? {
        
        var propertyType: String? = nil
        var propertyAttributes: String? = nil
        
        // Get Class of property.
        let objectClass: AnyClass = object_getClass(self)
        let property = class_getProperty(objectClass, name);
        
        // Try to get getter method.
        if (property == nil)
        {
            //            char typeCString[256];
            
            let typeCString: UnsafeMutablePointer<Int8> = nil
            let getter = class_getInstanceMethod(objectClass, NSSelectorFromString(name));
            method_getReturnType(getter, typeCString, 256);
            propertyAttributes = String.fromCString(typeCString)
            
            // Mimic type encoding for `typeNameForTypeEncoding:`.
            propertyType = self.typeNameForTypeEncoding(NSString(format: "T%", propertyAttributes!) as String);
            
            if (getter == nil)
            { NSLog("No property called `%@` of %", name, self.className); }
        }
            
            // Or go on with property attribute parsing.
        else
        {
            // Get property attributes.
            //            const char *propertyAttributesCString;
            let propertyAttributesCString = property_getAttributes(property);
            let propertyAttributes = String.fromCString(propertyAttributesCString)
            
            if (propertyAttributesCString == nil)
            { print("Could not get attributes for property called `\(name)` of <\(self.className)>"); }
            
            // Parse property attributes.
            if let splitPropertyAttributes = propertyAttributes?.componentsSeparatedByString(",") where splitPropertyAttributes.count > 0 {
                // From Objective-C Runtime Programming Guide.
                // xcdoc://ios//library/prerelease/ios/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
                let encodeType = splitPropertyAttributes[0]
                let splitEncodeType = encodeType.componentsSeparatedByString("\"")
                propertyType = (splitEncodeType.count > 1) ? splitEncodeType[1] : self.typeNameForTypeEncoding(encodeType)
            }
            else
            { print("Could not parse attributes for property called `\(name)` of <\(self.className)>") }
        }
        
        return propertyType;
    }
    
    func typeNameForTypeEncoding(typeEncoding: String) -> String?
    {
        // From Objective-C Runtime Programming Guide.
        // xcdoc://ios//library/prerelease/ios/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
        let typeNamesForTypeEncodings = ["Tc" : "char",
            "Ti" : "int",
            "Ts" : "short",
            "Tl" : "long",
            "Tq" : "long long",
            "TC" : "unsigned char",
            "TI" : "unsigned int",
            "TS" : "unsigned short",
            "TL" : "unsigned long",
            "TQ" : "unsigned long long",
            "Tf" : "float",
            "Td" : "double",
            "Tv" : "void",
            "T*" : "char*",
            "T" : "id",
            "T#" : "Class",
            "T:" : "SEL",
            
            "T^c" : "char*",
            "T^i" : "int*",
            "T^s" : "short*",
            "T^l" : "long*",
            "T^q" : "long long*",
            "T^C" : "unsigned char*",
            "T^I" : "unsigned int*",
            "T^S" : "unsigned short*",
            "T^L" : "unsigned long*",
            "T^Q" : "unsigned long long*",
            "T^f" : "float*",
            "T^d" : "double*",
            "T^v" : "void*",
            "T^*" : "char**"]
        
        // Recognized format.
        if typeNamesForTypeEncodings.keys.contains(typeEncoding)
        { return typeNamesForTypeEncodings[typeEncoding] }
        
        // Struct property.
        if typeEncoding.hasPrefix("T{")
        {
            // Try to get struct name.
            let delimiters = NSCharacterSet(charactersInString:"{=")
            let components = typeEncoding.componentsSeparatedByCharactersInSet(delimiters)
            
            var structName: String = ""
            
            if (components.count > 1)
            { structName = components[1]; }
            
            // Falls back to `struct` when unknown name encountered.
            if structName == "?" {
                structName = "struct"
            }
            
            return structName;
        }
        
        // Falls back to raw encoding if none of the above.
        return typeEncoding;
    }
    
    public func objcPropertyCollectionObjectType(key: String) -> AnyClass? {
        
        return nil
    }
}


//MARK: Swift Properties

extension NSObject {
    
    public var swiftProperties: [String] {
        
        return self.swiftProperties(false)
    }
    
    public func swiftProperties(includeNSObject: Bool) -> [String] {
        
        return Mirror(reflecting: self).allLabels
    }
    
    public var swiftReadWriteProperties: [String] {
        
        let propertyNames = self.swiftProperties
        var readWrite: [String] = []
        
        for name in propertyNames {
            
            let capitalized = name.capitalizedFirstLetter
            let selector = "set\(capitalized):"
            if self.respondsToSelector(Selector(selector)) {
                readWrite.append(name)
            }
        }
        
        return readWrite
    }
    
    public func swiftClassOfProperty(name: String) -> AnyClass? {
        
        if let type = self.swiftPropertyType(name) {
            
            let components = type.stringByReplacingOccurrencesOfString(">", withString: "").componentsSeparatedByString("<")
            
            let bundleClass = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as! String + "." + components.last!
            if  let returnClass = NSClassFromString(bundleClass) {
                
                return returnClass
            }
        }
        
        return nil
    }
    
    public func swiftPropertyType(name:String)->String?
    {
        let type: Mirror = Mirror(reflecting:self)
        
        for child in type.children {
            if child.label! == name
            {
                return String(child.value.dynamicType)
            }
        }
        return nil
    }
    
    public var className: String {
        return self.dynamicType.className
    }
    
    public class var className: String {
        return String(self)
    }
}


import ObjectiveC

final class Lifted<T> {
    let value: T
    init(_ x: T) {
        value = x
    }
}

public extension NSObject {
    
    private func lift<T>(x: T?) -> Lifted<T>?  {
        if x == nil {
            return nil
        }
        
        return Lifted(x!)
    }
    
    func setAssociatedObject<T>(object: AnyObject, value: T?, associativeKey: UnsafePointer<Void>, policy: objc_AssociationPolicy) {
        if let v: AnyObject = value as? AnyObject {
            objc_setAssociatedObject(object, associativeKey, v,  policy)
        }
        else {
            objc_setAssociatedObject(object, associativeKey, lift(value),  policy)
        }
    }
    
    func getAssociatedObject<T>(object: AnyObject, associativeKey: UnsafePointer<Void>) -> T? {
        if let v = objc_getAssociatedObject(object, associativeKey) as? T {
            return v
        }
        else if let v = objc_getAssociatedObject(object, associativeKey) as? Lifted<T> {
            return v.value
        }
        else {
            return nil
        }
    }
}


//MARK: To Dict

//extension NSObject {
//    
//    var prettyPrint: String{
//        
//        if NSJSONSerialization.isValidJSONObject(self) {
//            
//            let data: NSData?
//            do {
//                data = try NSJSONSerialization.dataWithJSONObject(self, options: .PrettyPrinted)
//            }
//            catch {
//                data = nil
//            }
//            
//            if let data = data, let string = String(data: data, encoding: NSUTF8StringEncoding) {
//                return string
//            }
//        }
//        return ""
//    }
//}