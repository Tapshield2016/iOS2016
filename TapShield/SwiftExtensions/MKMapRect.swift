//
//  MKMapRect.swift
//  Pods
//
//  Created by Adam J Share on 11/1/15.
//
//

import MapKit

public extension MKMapRect {
    
    func isEqualRounded(rect: MKMapRect) -> Bool {
        
        return (round(self.size.height) == round(rect.size.height) &&
            round(self.size.width) == round(rect.size.width) &&
            round(self.origin.x) == round(rect.origin.x) &&
            round(self.origin.y) == round(rect.origin.y));
    }
}

