//
//  TSGeofence.m
//  TestTapShield
//
//  Created by Adam Share on 12/11/13.
//  Copyright (c) 2013 TapShield. All rights reserved.
//

#import "TSGeofence.h"

#import "TSJavelinAlertManager.h"
#import "TSJavelinAPIClient.h"

//#import "TSLocalNotifications.h"
//#import "TSWarningViewController.h"
//#import "TSNotificationView.h"

NSString * const TSGeofenceUserIsInitiallyWithinBoundariesWithOverhang = @"TSGeofenceUserIsInitiallyWithinBoundariesWithOverhang";
NSString * const TSGeofenceUserIsWithinBoundariesWithOverhang = @"TSGeofenceUserIsWithinBoundariesWithOverhang";
NSString * const TSGeofenceUserIsOutsideBoundariesWithOverhang = @"TSGeofenceUserIsOutsideBoundariesWithOverhang";
NSString * const TSGeofenceUserIsInitiallyOutsideBoundariesWithOverhang = @"TSGeofenceUserIsInitiallyOutsideBoundariesWithOverhang";


@implementation TSGeofence

+ (BOOL)isLocation:(CLLocation *)location insideGeofence:(NSArray *)geofencePolygon {
    
    double currentLocationX = location.coordinate.latitude;
    double currentLocationY = location.coordinate.longitude;
    NSLog(@"x - %.10f, y - %.10f", currentLocationX, currentLocationY);
    
    if (geofencePolygon.count < 3) {
        return YES;
    }
    
    CGMutablePathRef geofencePath = CGPathCreateMutable();
    for (int i = 0; i < geofencePolygon.count; i++) {
        double geofenceX = ((CLLocation *)geofencePolygon[i]).coordinate.latitude;
        double geofenceY = ((CLLocation *)geofencePolygon[i]).coordinate.longitude;
        if (i == 0) {
            CGPathMoveToPoint(geofencePath, NULL, geofenceX, geofenceY);
        }
        else {
            CGPathAddLineToPoint(geofencePath, NULL, geofenceX, geofenceY);
        }
    }
    CGPathCloseSubpath(geofencePath);
    BOOL inside = CGPathContainsPoint(geofencePath, NULL, CGPointMake(currentLocationX, currentLocationY), YES);
    CGPathRelease(geofencePath);
    if (inside) {
        return YES;
    }
    return NO;
}


+ (double) distanceFromPoint:(CLLocation *)location toGeofencePolygon:(NSArray *)geofencePolygon
{
    double x3 = location.coordinate.latitude;
    double y3 = location.coordinate.longitude;
    double shortestDistanceInMeters = 0.0;
    NSLog(@"Your Location: %f,%f", x3, y3);
    if (geofencePolygon.count < 3) {
        return 99999999999;
    }
    
    for (int i = 0; i < geofencePolygon.count; i++) {
        double x1 = ((CLLocation *)geofencePolygon[i]).coordinate.latitude;
        double y1 = ((CLLocation *)geofencePolygon[i]).coordinate.longitude;
        double x2;
        double y2;
        //return to original point to close polygon
        if (((CLLocation *)geofencePolygon[i]).coordinate.latitude == ((CLLocation *)[geofencePolygon lastObject]).coordinate.latitude) {
            x2 = ((CLLocation *)geofencePolygon[0]).coordinate.latitude;
            y2 = ((CLLocation *)geofencePolygon[0]).coordinate.longitude;
        }
        else {
            x2 = ((CLLocation *)geofencePolygon[i+1]).coordinate.latitude;
            y2 = ((CLLocation *)geofencePolygon[i+1]).coordinate.longitude;
        }
        //calculate the percentage of the distance between (x1,y1) and (x2,y2)
        double lineMagnitude = sqrt(pow((x2 - x1), 2.0) + pow((y2 - y1), 2.0));
        double u1 = ((x3 - x1)*(x2 - x1))+((y3 - y1)*(y2 - y1));
        double u =  u1 / (lineMagnitude * lineMagnitude);
        if (lineMagnitude == 0) {
            continue;
        }
        //NSLog(@"u = %f", u);
        //point (x1, y1) is closest
        if (u < 0) {
            u = 0;
        }
        //point (x2, y2) is closest
        else if (u > 1) {
            u = 1;
        }
        //closest point on the line
        double xu = x1 + u * (x2 - x1);
        double yu = y1 + u * (y2 - y1);
        
        //NSLog(@"point: %f,%f", xu, yu);
        
        CLLocation *coordinatePoint = [[CLLocation alloc] initWithLatitude:xu longitude:yu];
        double newDistance = [location distanceFromLocation:coordinatePoint];
        
        if (shortestDistanceInMeters == 0.0) {
            shortestDistanceInMeters = [location distanceFromLocation:coordinatePoint];
            NSLog(@"closest point: %f,%f", xu, yu);
        }
        if (newDistance < shortestDistanceInMeters) {
            shortestDistanceInMeters = newDistance;
            NSLog(@"closest point: %f,%f", xu, yu);
        }
    }
    return shortestDistanceInMeters;
}

+ (bool)isWithinBoundariesWithOverhang:(CLLocation *)location
{
    
    double metersFromBoundary = [TSGeofence distanceFromPoint:location toGeofencePolygon:[[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].agency.agencyBoundaries];
    bool isInsideGeofence = [TSGeofence isLocation:location insideGeofence:[[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].agency.agencyBoundaries];
    
    NSLog(@"%fm From Boundary", metersFromBoundary);
    NSLog(@"%fm Accuracy", location.horizontalAccuracy);
    NSLog(@"Accuracy - MetersFromBoundary = %fm", location.horizontalAccuracy - metersFromBoundary);
    
    if (isInsideGeofence) {
        NSLog(@"isInsideGeofence");
        if (metersFromBoundary > location.horizontalAccuracy - metersFromBoundary) {
            NSLog(@"InsideGeofence and (metersFromBoundary < location.horizontalAccuracy - metersFromBoundary)");
            return YES;
        }
    }
//#warning GeoTesting
//        return YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TSGeofenceUserIsOutsideBoundariesWithOverhang
                                                        object:nil];
    
    [[TSJavelinAPIClient sharedClient] cancelAlert];
    
    return NO;
}

+ (bool)isInitiallyWithinBoundariesWithOverhang:(CLLocation *)location
{
    double metersFromBoundary = [TSGeofence distanceFromPoint:location toGeofencePolygon:[[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].agency.agencyBoundaries];
    bool isInsideGeofence = [TSGeofence isLocation:location insideGeofence:[[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].agency.agencyBoundaries];
    
    NSLog(@"%fm From Boundary", metersFromBoundary);
    NSLog(@"%fm Accuracy", location.horizontalAccuracy);
    NSLog(@"Accuracy - MetersFromBoundary = %fm", location.horizontalAccuracy - metersFromBoundary);
    if (isInsideGeofence) {
        return YES;
        NSLog(@"isInsideGeofence");
    }
    if (!isInsideGeofence && metersFromBoundary < location.horizontalAccuracy - metersFromBoundary) {
        NSLog(@"NotInsideGeofence but (metersFromBoundary < location.horizontalAccuracy - metersFromBoundary)");
            return YES;
    }
    NSLog(@"Initially Outside Geofence");
//#warning GeoTesting
//        return YES;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TSGeofenceUserIsInitiallyOutsideBoundariesWithOverhang
                                                        object:nil];
    
    [[TSJavelinAPIClient sharedClient] cancelAlert];
    
    return NO;
}




@end
