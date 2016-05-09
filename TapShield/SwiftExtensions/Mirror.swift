//
//  Mirror.swift
//  Pods
//
//  Created by Adam J Share on 11/4/15.
//
//

import Foundation

public extension Mirror {
    
    public var allLabels: [String] {
        
        var childLabels = self.childLabels
        
        if let superMirror = self.superclassMirror() {
            childLabels = childLabels.union(superMirror.allLabels)
        }
        
        return childLabels
    }
    
    
    
    public var childLabels: [String] {
        
        var labels = [String]()
        
        for children in self.children {
            
            if let label = children.label{
                labels.append(label)
            }
        }
        
        return labels
    }
}