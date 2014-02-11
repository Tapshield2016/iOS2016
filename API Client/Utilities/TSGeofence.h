//
//  TSGeofence.h
//  TestTapShield
//
//  Created by Adam Share on 12/11/13.
//  Copyright (c) 2013 TapShield. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface TSGeofence : NSObject

+ (double) distanceFromPoint:(CLLocation *)location toGeofencePolygon:(NSArray *)geofencePolygon;
+ (BOOL)isLocation:(CLLocation *)location insideGeofence:(NSArray *)geofencePolygon;
+ (bool)isWithinBoundariesWithOverhang:(CLLocation *)location;
+ (bool)isInitiallyWithinBoundariesWithOverhang:(CLLocation *)location;

extern NSString * const TSGeofenceUserIsInitiallyWithinBoundariesWithOverhang;
extern NSString * const TSGeofenceUserIsWithinBoundariesWithOverhang;
extern NSString * const TSGeofenceUserIsOutsideBoundariesWithOverhang;
extern NSString * const TSGeofenceUserIsInitiallyOutsideBoundariesWithOverhang;

@end
