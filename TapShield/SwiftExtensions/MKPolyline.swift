//
//  MKPolyline.swift
//  Pods
//
//  Created by Adam J Share on 11/6/15.
//
//

import MapKit


public extension MKPolyline {
    
    func polyLineFromPoint(point: MKMapPoint) -> MKPolyline {
        
        var removeToPointIndex = 0
        var initialPoint: MKMapPoint = MKMapPoint(x: 0, y: 0)
        var distance: CLLocationDistance = Double.infinity
        
        let points = self.points()
        
        for n in 0 ..< self.pointCount - 1 {
            
            let ptA = points[n];
            let ptB = points[n + 1];
            
            let xDelta = ptB.x - ptA.x;
            let yDelta = ptB.y - ptA.y;
            
            if (xDelta == 0.0 && yDelta == 0.0) {
                
                // Points must not be equal
                continue;
            }
            
            let u = ((point.x - ptA.x) * xDelta + (point.y - ptA.y) * yDelta) / (xDelta * xDelta + yDelta * yDelta);
            var pointClosest: MKMapPoint
            if (u < 0.0) {
                
                pointClosest = ptA;
            }
            else if (u > 1.0) {
                
                pointClosest = ptB;
            }
            else {
                
                pointClosest = MKMapPointMake(ptA.x + u * xDelta, ptA.y + u * yDelta);
            }
            
            let compareDistance = MKMetersBetweenMapPoints(pointClosest, point);
            if (compareDistance < distance) {
                distance = compareDistance;
                initialPoint = pointClosest
                removeToPointIndex = n
            }
        }
        
        let pointCount = self.pointCount
        
        let newMapPointCount = pointCount-removeToPointIndex
        let newMapPoints: UnsafeMutablePointer<MKMapPoint> = UnsafeMutablePointer<MKMapPoint>(malloc(newMapPointCount * sizeof(MKMapPoint)))
        
        newMapPoints[0] = initialPoint;
        
        var j = 1;
        for i in removeToPointIndex+1 ..< pointCount {
            
            let point = points[i]
            newMapPoints[j] = point;
            j += 1;
        }
        
        return MKPolyline(points: newMapPoints, count:newMapPointCount)
    }
    
    
    
    func distanceToEndFromPoint(point: MKMapPoint) -> CLLocationDistance {
    
        let newPolyline = self.polyLineFromPoint(point)
    
        var distance: CLLocationDistance = 0
        
        let points = newPolyline.points()
        let count = newPolyline.pointCount
    
        for i in 0 ..< count - 1 {
    
            distance += MKMetersBetweenMapPoints(points[i], points[i+1]);
        }
    
        return distance;
    }
    
    func distanceFromLocation(location: CLLocation?) -> CLLocationDistance {
        if let point = location?.mapPoint {
            return self.distanceFromPoint(point)
        }
        return 0
    }
    
    func distanceFromPoint(point: MKMapPoint) -> CLLocationDistance {
        
        let pointClosest = self.closestPoint(point)
        
        return MKMetersBetweenMapPoints(pointClosest, point)
    }
    
    func closestPoint(point: MKMapPoint) -> MKMapPoint {
        
        var distance = DBL_MAX
        
        var returnPoint = MKMapPointMake(0, 0)
        
        for i in 0..<self.pointCount {
            
            let ptA = self.points()[i];
            let ptB = self.points()[i+1];
            
            let xDelta = ptB.x - ptA.x;
            let yDelta = ptB.y - ptA.y;
            
            if (xDelta == 0.0 && yDelta == 0.0) {
                // Points must not be equal
                continue;
            }
            
            let u = ((point.x - ptA.x) * xDelta + (point.y - ptA.y) * yDelta) / (xDelta * xDelta + yDelta * yDelta);
            
            var pointClosest: MKMapPoint
            
            if (u < 0.0) {
                pointClosest = ptA;
            }
            else if (u > 1.0) {
                pointClosest = ptB;
            }
            else {
                pointClosest = MKMapPointMake(ptA.x + u * xDelta, ptA.y + u * yDelta);
            }
            
            let compareDistance = MKMetersBetweenMapPoints(pointClosest, point);
            
            if (compareDistance < distance) {
                
                distance = compareDistance;
                returnPoint = pointClosest;
            }
        }
        
        return returnPoint
    }
}



/*


- (void)encodeWithCoder:(NSCoder *)coder {

    [coder encodeInteger:self.pointCount forKey:@"pointCount"];
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.subtitle forKey:@"subtitle"];

    MKMapPoint *points = self.points;
    NSData *pointData = [NSData dataWithBytes:points length:self.pointCount * sizeof(MKMapPoint)];
    [coder encodeObject:pointData forKey:@"points"];
    }

    - (id)initWithCoder:(NSCoder *)coder {

        NSData *pointData = [coder decodeObjectForKey:@"points"];
        MKMapPoint *points = (MKMapPoint*)[pointData bytes];

        self = [MKPolyline polylineWithPoints:points count:[coder decodeIntegerForKey:@"pointCount"]];
        if (self) {

            self.title = [coder decodeObjectForKey:@"title"];
            self.subtitle = [coder decodeObjectForKey:@"subtitle"];
        }
        return self;
        }


                - (CLLocationDistance)distanceOfPoint:(MKMapPoint)point {

                    MKMapPoint pointClosest = pointClosest = [self closestPoint:point];
                    
                    return MKMetersBetweenMapPoints(pointClosest, point);
                    }
                    
                    - (MKMapPoint)closestPoint:(MKMapPoint)point {
                        CLLocationDistance distance = MAXFLOAT;
                        MKMapPoint returnPoint = MKMapPointMake(0, 0);
                        for (int n = 0; n < self.pointCount - 1; n++) {
                            
                            MKMapPoint ptA = self.points[n];
                            MKMapPoint ptB = self.points[n + 1];
                            
                            double xDelta = ptB.x - ptA.x;
                            double yDelta = ptB.y - ptA.y;
                            
                            if (xDelta == 0.0 && yDelta == 0.0) {
                                
                                // Points must not be equal
                                continue;
                            }
                            
                            double u = ((point.x - ptA.x) * xDelta + (point.y - ptA.y) * yDelta) / (xDelta * xDelta + yDelta * yDelta);
                            MKMapPoint pointClosest;
                            if (u < 0.0) {
                                
                                pointClosest = ptA;
                            }
                            else if (u > 1.0) {
                                
                                pointClosest = ptB;
                            }
                            else {
                                
                                pointClosest = MKMapPointMake(ptA.x + u * xDelta, ptA.y + u * yDelta);
                            }
                            
                            CLLocationDistance compareDistance = MKMetersBetweenMapPoints(pointClosest, point);
                            if (compareDistance < distance) {
                                distance = compareDistance;
                                returnPoint = pointClosest;
                            }
                        }
                        
                        return returnPoint;
}
*/
