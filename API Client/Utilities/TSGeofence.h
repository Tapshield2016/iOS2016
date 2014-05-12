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
+ (BOOL)isWithinBoundariesWithOverhang:(CLLocation *)location agency:(TSJavelinAPIAgency *)agency;
+ (BOOL)isInitiallyWithinBoundariesWithOverhang:(CLLocation *)location;

//Roaming Organization
- (void)updateProximityToAgencies:(CLLocation *)currentLocation;
+ (void)registerForAgencyProximityUpdates:(id)object action:(SEL)selector;

//Outside
- (void)showOutsideBoundariesWindow;

extern NSString * const TSGeofenceUserIsInitiallyWithinBoundariesWithOverhang;
extern NSString * const TSGeofenceUserIsWithinBoundariesWithOverhang;
extern NSString * const TSGeofenceUserIsOutsideBoundariesWithOverhang;
extern NSString * const TSGeofenceUserIsInitiallyOutsideBoundariesWithOverhang;

extern NSString * const TSGeofenceUserDidEnterAgency;
extern NSString * const TSGeofenceUserDidLeaveAgency;

@end
