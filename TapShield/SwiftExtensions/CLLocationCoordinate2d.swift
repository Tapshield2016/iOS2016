//
//  CLLocationCoordinate2d.swift
//  Pods
//
//  Created by Adam J Share on 11/1/15.
//
//

import Foundation
import CoreLocation


public extension CLLocationCoordinate2D {
    
    func isEqual(coordinate: CLLocationCoordinate2D, margin: CLLocationDegrees = 0) -> Bool {
        
        return (fabs(self.latitude - coordinate.latitude) <= margin &&
            fabs(self.longitude - coordinate.longitude) <= margin);
    }
    
    func coordinateOffset(latitudeChange: CLLocationDegrees, longitudeChange: CLLocationDegrees) -> CLLocationCoordinate2D {
        
        return CLLocationCoordinate2D(latitude: self.latitude + latitudeChange, longitude: self.longitude + longitudeChange)
    }
    
    func coordinateRounded(decimalPlace: Double) -> CLLocationCoordinate2D {
        
        return CLLocationCoordinate2D(latitude: self.latitude.roundToDecimal(decimalPlace), longitude: self.longitude.roundToDecimal(decimalPlace))
    }
    
    
    func coordinateWithDistance(meters: CLLocationDistance, bearing: CLLocationDirection) -> CLLocationCoordinate2D {
        
        let coordinateLatitudeInRadians = Double(self.latitude * M_PI / 180)
        let coordinateLongitudeInRadians = Double(self.longitude * M_PI / 180)
        let bearingInRadians = Double(bearing.degreesToRadians)
        
        let distanceComparedToEarth = meters / 6378100;
        
        let resultLatitudeInRadians = asin(sin(coordinateLatitudeInRadians) * cos(distanceComparedToEarth) + cos(coordinateLatitudeInRadians) * sin(distanceComparedToEarth) * cos(bearingInRadians));
        let resultLongitudeInRadians = coordinateLongitudeInRadians + atan2(sin(bearingInRadians) * sin(distanceComparedToEarth) * cos(coordinateLatitudeInRadians), cos(distanceComparedToEarth) - sin(coordinateLatitudeInRadians) * sin(resultLatitudeInRadians));
        
        return CLLocationCoordinate2D(latitude: resultLatitudeInRadians * 180 / M_PI, longitude: resultLongitudeInRadians * 180 / M_PI)
    }
    /*
    + (CLLocationCoordinate2D)calculateCoordinateFrom:(CLLocationCoordinate2D)coordinate onBearing:(double)bearingInRadians atDistance:(double)distanceInMetres {
    
    
    }
*/
}


