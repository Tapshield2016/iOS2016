//
//  MKRouteStepPolyline+EncodeDecode.m
//  TapShield
//
//  Created by Adam Share on 12/2/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "MKPolyline+EncodeDecode.h"

@interface MKPolyline ()


@end


@implementation MKPolyline (EncodeDecode)

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


- (MKPolyline *)polyLineFromPoint:(MKMapPoint)point {
    
    MKMapPoint removeToPoint;
    
    double distance = MAXFLOAT;
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
        
        double compareDistance = MKMetersBetweenMapPoints(pointClosest, point);
        if (compareDistance < distance) {
            distance = compareDistance;
            returnPoint = pointClosest;
            removeToPoint = ptA;
        }
    }
    
    MKMapPoint *newMapPoints = NULL;
    NSUInteger newMapPointCount = 0;
    BOOL shouldAddPoint = NO;
    int j = 0;
    
    for (int i = 0; i < self.pointCount; i++) {
        
        if (shouldAddPoint) {
            newMapPoints[j] = self.points[i];
            j++;
        }
        else if (MKMapPointEqualToPoint(self.points[i], removeToPoint)) {
            shouldAddPoint = YES;
            
            newMapPointCount = self.pointCount - i;
            newMapPoints = malloc(newMapPointCount * sizeof(MKMapPoint));
            newMapPoints[j] = removeToPoint;
            j++;
        }
    }
    
    return [MKPolyline polylineWithPoints:newMapPoints count:newMapPointCount];
}

- (CLLocationDistance)distanceToEndFromPoint:(MKMapPoint)point {
    
    MKPolyline *newPolyline = [self polyLineFromPoint:point];
    
    CLLocationDistance distance = 0;
    
    for (int i = 0; i < newPolyline.pointCount - 1; i++) {
        
        distance += MKMetersBetweenMapPoints(newPolyline.points[i], newPolyline.points[i+1]);
    }
    
    return distance;
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


@end
