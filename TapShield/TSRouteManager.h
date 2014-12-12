//
//  TSRouteManager.h
//  TapShield
//
//  Created by Adam Share on 4/2/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSSelectedDestinationAnnotation.h"
#import "TSRouteManager.h"
#import "TSRouteOption.h"
#import "TSUtilities.h"
#import "TSMapView.h"
#import "TSRouteTimeAnnotationView.h"
#import "MKMapItem+EncodeDecode.h"
#import <MapKit/MapKit.h>

@interface TSRouteManager : NSObject

@property (nonatomic, weak) TSMapView *mapView;
@property (nonatomic, strong) TSRouteOption *selectedRoute;
@property (nonatomic, strong) NSArray *routeOptions;
@property (nonatomic, strong) NSArray *routingAnnotations;

// Virtual Entourage selected destination
@property (nonatomic, strong) TSSelectedDestinationAnnotation *destinationAnnotation;
@property (nonatomic, strong) MKMapItem *startingMapItem;
@property (nonatomic, strong) MKMapItem *destinationMapItem;
@property (nonatomic, assign) MKDirectionsTransportType destinationTransportType;

@property (nonatomic, strong) MKDirections *directions;

- (instancetype)initWithMapView:(MKMapView *)mapView;

- (void)updateTempMapItemLocation:(CLLocation *)location;
- (void)updateTempMapItemTransportType;

- (void)selectRouteClosestTo:(MKMapPoint)mapPoint;
- (void)selectedRouteAnnotationView:(TSRouteTimeAnnotationView *)routeAnnotationView;
- (void)addRouteOverlaysToMapViewAndAnnotations;
- (void)removeRouteOverlaysAndAnnotations;
- (void)removeCurrentDestinationAnnotation;
- (void)showOnlySelectedRoute;
- (void)showDestinationAnnotation;

- (void)userSelectedDestination:(MKMapItem *)mapItem forTransportType:(MKDirectionsTransportType)transportType;
- (void)calculateETAForSelectedDestination:(void (^)(NSTimeInterval expectedTravelTime))completion;
- (void)calculateEtaAndDistanceForSelectedDestination:(void (^)(NSTimeInterval expectedTravelTime, CLLocationDistance distance))completion;

- (void)getRoutesForDestination:(void (^)(TSRouteOption *bestRoute, NSError *error))completion;

- (void)cancelSearch;

@end
