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

+ (BOOL)isWithinBoundariesWithOverhangAndOpen;
+ (BOOL)isInsideOpenRegion;
+ (TSJavelinAPIRegion *)regionInside;
+ (NSString *)primaryPhoneNumberInsideRegion;
+ (NSArray *)openDispatchCenters;
+ (BOOL)insideButClosed;

+ (double) distanceFromPoint:(CLLocation *)location toGeofencePolygon:(NSArray *)geofencePolygon;
+ (BOOL)isLocation:(CLLocation *)location insideGeofence:(NSArray *)geofencePolygon;
+ (BOOL)isWithinBoundariesWithOverhang:(CLLocation *)location boundaries:(NSArray *)boundaries;
+ (BOOL)isInitiallyWithinBoundariesWithOverhang:(CLLocation *)location;
+ (BOOL)isWithinBoundariesWithOverhangAndOpen:(CLLocation *)location agency:(TSJavelinAPIAgency *)agency;
+ (TSJavelinAPIRegion *)regionInside:(TSJavelinAPIAgency *)agency location:(CLLocation *)location;

+ (NSString *)primaryPhoneNumberInsideRegion:(CLLocation *)location agency:(TSJavelinAPIAgency *)agency;

//Roaming Organization
- (void)updateProximityToAgencies:(CLLocation *)currentLocation;
- (void)updateNearbyAgencies:(CLLocation *)currentLocation;
+ (void)registerForAgencyProximityUpdates:(id)object action:(SEL)selector;

- (TSJavelinAPIAgency *)nearbyAgencyWithID:(NSString *)identifier;
- (TSJavelinAPIRegion *)nearbyAgencyRegionWithID:(NSString *)identifier;

//Outside
- (void)showOutsideBoundariesWindow;

extern NSString * const TSGeofenceUserIsInitiallyWithinBoundariesWithOverhang;
extern NSString * const TSGeofenceUserIsWithinBoundariesWithOverhang;
extern NSString * const TSGeofenceUserIsOutsideBoundariesWithOverhang;
extern NSString * const TSGeofenceUserIsInitiallyOutsideBoundariesWithOverhang;

extern NSString * const TSGeofenceUserDidEnterAgency;
extern NSString * const TSGeofenceUserDidLeaveAgency;

@end
