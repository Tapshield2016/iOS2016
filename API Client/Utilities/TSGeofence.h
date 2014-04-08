//
//  TSGeofence.h
//  TestTapShield
//
//  Created by Adam Share on 12/11/13.
//  Copyright (c) 2013 TapShield. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "TSJavelinAPIClient.h"

@interface TSGeofence : NSObject

@property (strong, nonatomic) TSJavelinAPIAgency *currentAgency;
@property (strong, nonatomic) NSArray *nearbyAgencies;
@property (strong, nonatomic) CLLocation *lastAgencyUpdate;
@property (assign, nonatomic) double distanceToNearestAgencyBoundary;

+ (double) distanceFromPoint:(CLLocation *)location toGeofencePolygon:(NSArray *)geofencePolygon;
+ (BOOL)isLocation:(CLLocation *)location insideGeofence:(NSArray *)geofencePolygon;
+ (bool)isWithinBoundariesWithOverhang:(CLLocation *)location agency:(TSJavelinAPIAgency *)agency;
+ (bool)isInitiallyWithinBoundariesWithOverhang:(CLLocation *)location;

//Roaming Organization
- (void)updateProximityToAgencies:(CLLocation *)currentLocation;

extern NSString * const TSGeofenceUserIsInitiallyWithinBoundariesWithOverhang;
extern NSString * const TSGeofenceUserIsWithinBoundariesWithOverhang;
extern NSString * const TSGeofenceUserIsOutsideBoundariesWithOverhang;
extern NSString * const TSGeofenceUserIsInitiallyOutsideBoundariesWithOverhang;

@end
