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
#import "TSSpotCrimeAnnotation.h"
#import "TSUserAnnotationView.h"
//#import "OCMapview.h"
#import "ADClusterMapView.h"

#define kMaxLonDeltaCluster 0.1

@interface TSMapView : ADClusterMapView

@property (nonatomic, strong) CLLocation *previousLocation;
@property (nonatomic, strong) CLLocation *lastReverseGeocodeLocation;
@property (nonatomic, strong) MKCircle *accuracyCircle;
@property (nonatomic, strong) TSMapOverlayCircle *animatedOverlay;
@property (nonatomic, strong) TSUserLocationAnnotation *userLocationAnnotation;
@property (nonatomic, strong) TSUserAnnotationView *userLocationAnnotationView;

@property (nonatomic) BOOL isAnimatingToRegion;
@property (nonatomic) BOOL shouldUpdateCallOut;

+ (MKOverlayRenderer *)mapViewPolygonOverlay:(id<MKOverlay>)overlay;
+ (MKOverlayRenderer *)mapViewCircleOverlay:(id<MKOverlay>)overlay;

- (void)setRegionAtAppearanceAnimated:(BOOL)animated;
- (void)refreshRegionBoundariesOverlay;
- (void)updateAccuracyCircleWithLocation:(CLLocation *)location;
- (void)adjustAnnotationAlphaForPan;

//animated radius
- (void)addAnimatedOverlayToAnnotation:(id<MKAnnotation>)annotation;
- (void)removeAnimatedOverlay;
- (void)resetAnimatedOverlayAt:(CLLocation *)location;

@end
