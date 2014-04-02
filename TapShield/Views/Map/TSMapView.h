//
//  TSMapView.h
//  TapShield
//
//  Created by Adam Share on 2/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "TSJavelinAPIClient.h"
#import "TSUserLocationAnnotation.h"
#import "TSAgencyAnnotation.h"
#import "TSAppDelegate.h"
#import "TSColorPalette.h"
#import "TSMapOverlayCircle.h"
#import "TSSelectedDestinationAnnotation.h"
#import "TSRouteTimeAnnotation.h"
#import "TSRouteOption.h"

@interface TSMapView : MKMapView

@property (nonatomic, strong) NSArray *geofenceArray;
@property (nonatomic, strong) CLLocation *previousLocation;
@property (nonatomic, strong) CLLocation *lastReverseGeocodeLocation;
@property (nonatomic, strong) MKCircle *accuracyCircle;
@property (nonatomic, strong) TSMapOverlayCircle *animatedOverlay;
@property (nonatomic, strong) TSUserLocationAnnotation *userLocationAnnotation;

// Virtual Entourage selected destination
// Probably need to find another place to stuff these things, feels a little sloppy
@property (nonatomic, strong) MKMapItem *destinationMapItem;
@property (nonatomic, strong) TSSelectedDestinationAnnotation *destinationAnnotation;
@property (nonatomic, strong) NSArray *routeOptionsArray;
@property (nonatomic, assign) MKDirectionsTransportType destinationTransportType;

@property (nonatomic) BOOL isAnimatingToRegion;
@property (nonatomic) BOOL shouldUpdateCallOut;

+ (MKOverlayRenderer *)mapViewPolygonOverlay:(id<MKOverlay>)overlay;
+ (MKOverlayRenderer *)mapViewCircleOverlay:(id<MKOverlay>)overlay;

- (void)setRegionAtAppearanceAnimated:(BOOL)animated;
- (void)updateAccuracyCircleWithLocation:(CLLocation *)location;
- (void)adjustAnnotationAlphaForPan;

//Destination Annotation
- (void)userSelectedDestination:(MKMapItem *)mapItem forTransportType:(MKDirectionsTransportType)transportType;
- (void)centerMapOnSelectedDestination;
- (void)selectDestinationAnnotation;
- (void)removeCurrentDestinationAnnotation;

//animated radius
- (void)addAnimatedOverlayToAnnotation:(id<MKAnnotation>)annotation;
- (void)removeAnimatedOverlay;
- (void)resetAnimatedOverlayAt:(CLLocation *)location;

@end
