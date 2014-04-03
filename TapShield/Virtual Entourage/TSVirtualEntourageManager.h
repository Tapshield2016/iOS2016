//
//  TSVirtualEntourageManager.h
//  TapShield
//
//  Created by Adam Share on 4/2/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSSelectedDestinationAnnotation.h"
#import "TSRouteOption.h"
#import "TSMapView.h"
#import <MapKit/MapKit.h>

@interface TSVirtualEntourageManager : NSObject

@property (nonatomic, strong) TSMapView *mapView;
@property (nonatomic, strong) TSRouteOption *selectedRoute;
@property (nonatomic, strong) NSArray *routes;
@property (nonatomic, strong) NSArray *routeOptions;
@property (nonatomic, strong) NSArray *routingAnnotations;

// Virtual Entourage selected destination
@property (nonatomic, strong) TSSelectedDestinationAnnotation *destinationAnnotation;
@property (nonatomic, strong) MKMapItem *destinationMapItem;
@property (nonatomic, strong) NSArray *routeOptionsArray;
@property (nonatomic, assign) MKDirectionsTransportType destinationTransportType;

- (instancetype)initWithMapView:(MKMapView *)mapView;

- (void)selectRouteClosestTo:(MKMapPoint)mapPoint;
- (void)addRouteOverlaysToMapViewAndAnnotations;
- (void)removeRouteOverlaysAndAnnotations;
- (void)removeCurrentDestinationAnnotation;

- (void)userSelectedDestination:(MKMapItem *)mapItem forTransportType:(MKDirectionsTransportType)transportType;

@end
