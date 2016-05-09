//
//  MKMapSize.swift
//  Pods
//
//  Created by Adam J Share on 11/6/15.
//
//

import MapKit

public extension MKMapSize {
    
    func isGreaterThanOrEqual(size: MKMapSize) -> Bool {
        return self.isGreaterThan(size) || self.isEqual(size)
    }
    
    func isLessThanOrEqual(size: MKMapSize) -> Bool {
        return self.isLessThan(size) || self.isEqual(size)
    }
    
    func isGreaterThan(size: MKMapSize) -> Bool {
        return (round(self.height) > round(size.height) &&
            round(self.width) > round(size.width));
    }
    
    func isLessThan(size: MKMapSize) -> Bool {
        return (round(self.height) < round(size.height) &&
            round(self.width) < round(size.width));
    }
    
    func isEqual(size: MKMapSize) -> Bool {
        return (round(self.height) == round(size.height) &&
            round(self.width) == round(size.width));
    }
}