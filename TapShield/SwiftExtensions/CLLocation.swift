//
//  CLLocation.swift
//  Pods
//
//  Created by Adam J Share on 11/6/15.
//
//

import Foundation
import MapKit

public extension CLLocation {
    
    var mapPoint: MKMapPoint {
        
        return MKMapPointForCoordinate(self.coordinate)
    }
    
    public var toJSON: [String: AnyObject] {
        
        return ["latitude": self.coordinate.latitude, "longitude": self.coordinate.longitude, "timestamp": self.timestamp.iso8601String,]
    }
    
    public class func locationArrayToJSON(locations: [CLLocation]) -> [[String: AnyObject]] {
        
        var returnArray: [[String: AnyObject]] = []
        
        for location in locations {
            returnArray.append(location.toJSON)
        }
        
        return returnArray
    }
}