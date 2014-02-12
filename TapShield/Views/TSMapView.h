//
//  TSMapView.h
//  TapShield
//
//  Created by Adam Share on 2/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "TSCustomMapAnnotationUserLocation.h"
#import "TSMapOverlayCircle.h"

@interface TSMapView : MKMapView

@property (nonatomic, strong) NSArray *geofenceArray;
@property (nonatomic, retain) CLLocation *initialLocation;
@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, retain) TSCustomMapAnnotationUserLocation *userLocationAnnotation;
@property (nonatomic, strong) MKCircle *accuracyCircle;

@property (nonatomic) BOOL isAnimatingToRegion;

+ (MKOverlayRenderer *)mapViewPolygonOverlay:(id<MKOverlay>)overlay;
+ (MKOverlayRenderer *)mapViewCircleOverlay:(id<MKOverlay>)overlay;

- (void)setRegionAtAppearance;
- (void)updateAccuracyCircleWithLocation:(CLLocation *)location;

//animated radius
- (void)addAnimatedOverlayToAnnotation:(id<MKAnnotation>)annotation;
- (void)removeAnimatedOverlay;

@end
