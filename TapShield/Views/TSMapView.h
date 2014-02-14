//
//  TSMapView.h
//  TapShield
//
//  Created by Adam Share on 2/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "TSJavelinAPIClient.h"
#import "TSCustomMapAnnotationUserLocation.h"
#import "TSAgencyAnnotation.h"
#import "TSMapOverlayCircle.h"

@interface TSMapView : MKMapView

@property (nonatomic, strong) NSArray *geofenceArray;
@property (nonatomic, strong) CLLocation *initialLocation;
@property (nonatomic, strong) CLLocation *previousLocation;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) CLLocation *lastReverseGeocodeLocation;
@property (nonatomic, strong) TSCustomMapAnnotationUserLocation *userLocationAnnotation;
@property (nonatomic, strong) MKCircle *accuracyCircle;

@property (nonatomic) BOOL isAnimatingToRegion;
@property (nonatomic) BOOL shouldUpdateCallOut;

+ (MKOverlayRenderer *)mapViewPolygonOverlay:(id<MKOverlay>)overlay;
+ (MKOverlayRenderer *)mapViewCircleOverlay:(id<MKOverlay>)overlay;

- (void)setRegionAtAppearanceAnimated:(BOOL)animated;
- (void)updateAccuracyCircleWithLocation:(CLLocation *)location;

//animated radius
- (void)addAnimatedOverlayToAnnotation:(id<MKAnnotation>)annotation;
- (void)removeAnimatedOverlay;

@end
