//
//  NSRange.swift
//  Pods
//
//  Created by Adam J Share on 11/5/15.
//
//

import Foundation

public extension NSRange {
    func toRange(string: String) -> Range<String.Index> {
        let startIndex = string.startIndex.advancedBy(location)
        let endIndex = startIndex.advancedBy(length)
        return startIndex..<endIndex
    }
}