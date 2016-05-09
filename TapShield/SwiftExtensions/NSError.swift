//
//  NSError.swift
//  Pods
//
//  Created by Adam J Share on 12/1/15.
//
//

import Foundation

public extension NSError {
    
    public class var ravtiLocalErrorDomain: String { return "Local" }
    public class var ravtiLocalErrorCode: Int { return -100 }
    
    public convenience init(localErrorDescription: String? = nil, failureReason: String? = nil, recoverySuggestion: String? = nil) {
        
        var userInfo: [String: String] = [:]
        
        if let description = localErrorDescription {
            userInfo[NSLocalizedDescriptionKey] = description
            userInfo[NSLocalizedFailureReasonErrorKey] = description
        }
        
        if let failureReason = failureReason {
            userInfo[NSLocalizedFailureReasonErrorKey] = failureReason
        }
        
        if let recoverySuggestion = recoverySuggestion {
            userInfo[NSLocalizedRecoverySuggestionErrorKey] = recoverySuggestion
        }
        
        self.init(domain: NSError.ravtiLocalErrorDomain, code: NSError.ravtiLocalErrorCode, userInfo: userInfo)
    }
    
    class func localError(description: String? = nil, failureReason: String? = nil, recoverySuggestion: String? = nil) -> NSError {
        
        return NSError(localErrorDescription: description, failureReason: failureReason, recoverySuggestion: recoverySuggestion)
    }
}