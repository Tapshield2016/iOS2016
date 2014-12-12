//
//  TSRouteManager.m
//  TapShield
//
//  Created by Adam Share on 4/2/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSRouteManager.h"

@interface TSRouteManager ()

@property (nonatomic, strong) NSArray *routes;
@property (nonatomic, strong) MKMapItem *tempMapItem;

@end


@implementation TSRouteManager

- (instancetype)initWithMapView:(TSMapView *)mapView
{
    self = [super init];
    if (self) {
        self.mapView = mapView;
    }
    return self;
}


#pragma mark - Routing Methods

- (void)setRoutes:(NSArray *)routes {
    
    _routes = routes;
    
    NSMutableArray *mutableRouteOptions = [[NSMutableArray alloc] initWithCapacity:4];
    
    for (MKRoute *route in routes) {
        TSRouteOption *routeOption = [[TSRouteOption alloc] initWithRoute:route];
        [mutableRouteOptions addObject:routeOption];
    }
    
    self.routeOptions = mutableRouteOptions;
}


- (void)setRouteOptions:(NSArray *)routeOptions {
    
    _routeOptions = routeOptions;
    
    [self creatRouteAnnotations];
}

- (void)creatRouteAnnotations {
    
    NSMutableArray *annotationCoordinates = [[NSMutableArray alloc] initWithArray:@[_mapView.userLocationAnnotation, _destinationAnnotation]];
    
    for (TSRouteOption *routeOption in _routeOptions) {
        
        [routeOption findUniqueMapPointComparingRoutes:_routes completion:^(MKMapPoint uniquePointFromSet) {
            routeOption.routeTimeAnnotation = [[TSRouteTimeAnnotation alloc] initWithCoordinates:MKCoordinateForMapPoint(uniquePointFromSet) placeName:[TSUtilities formattedStringForDuration:routeOption.expectedTravelTime] description:@""];
            [annotationCoordinates addObject:routeOption.routeTimeAnnotation];
        }];
    }
    _routingAnnotations = annotationCoordinates;
    [self adjustAnnotationImageDirections];
}

- (void)adjustAnnotationImageDirections {
    
    for (TSRouteOption *routeOption in _routeOptions) {
        
        if (routeOption.routeTimeAnnotation) {
            [routeOption.routeTimeAnnotation setImageDirectionRelativeToStartingPoint:_mapView.userLocationAnnotation endingPoint:_destinationAnnotation];
            
            NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:_routeOptions];
            [mutableArray removeObject:routeOption];
            
            [routeOption.routeTimeAnnotation setImageDirectionRelativeToRouteOptions:mutableArray];
        }
    }
}

- (void)selectedRouteAnnotationView:(TSRouteTimeAnnotationView *)routeAnnotationView {
    
    for (TSRouteOption *routeOption in _routeOptions) {
        if (routeAnnotationView.annotation == routeOption.routeTimeAnnotation) {
            
            if (self.selectedRoute != routeOption) {
                [self setSelectedRouteFromStruckRoutes:@[routeOption]];
            }
            
            break;
        }
    }
}

- (void)setSelectedRoute:(TSRouteOption *)selectedRoute {
    
    _selectedRoute.routeTimeAnnotation.isSelected = NO;

    _selectedRoute = selectedRoute;
    
    _selectedRoute.routeTimeAnnotation.isSelected = YES;
}

- (void)selectRouteClosestTo:(MKMapPoint)mapPoint {
    
    double shortestDistance = INFINITY;
    
    // Capture multiple routes in case of overlap
    NSMutableArray *struckRoutes = [[NSMutableArray alloc] initWithCapacity:4];
    for (id overlay in _mapView.overlays) {
        if ([overlay isKindOfClass:[MKPolyline class]]) {
            MKPolyline *poly = (MKPolyline *) overlay;
            id view = [_mapView rendererForOverlay:poly];
            
            if ([view isKindOfClass:[MKPolylineRenderer class]]) {
                
                double distanceToPolyline = [TSUtilities distanceOfPoint:mapPoint toPoly:poly];
                if (distanceToPolyline < shortestDistance) {
                    
                    //Reset array to only include closest polyline
                    struckRoutes = [[NSMutableArray alloc] initWithCapacity:4];
                    shortestDistance = distanceToPolyline;
                    
                    for (TSRouteOption *routeOption in [NSArray arrayWithArray:_routeOptions]) {
                        if (routeOption.polyline == poly) {
                            [struckRoutes addObject:routeOption];
                        }
                    }
                }
                else if (distanceToPolyline == shortestDistance) {
                    for (TSRouteOption *routeOption in [NSArray arrayWithArray:_routeOptions]) {
                        if (routeOption.polyline == poly) {
                            [struckRoutes addObject:routeOption];
                        }
                    }
                }
            }
        }
    }
    [self setSelectedRouteFromStruckRoutes:struckRoutes];
}

- (void)setSelectedRouteFromStruckRoutes:(NSArray *)struckRoutes {
    
    if ([struckRoutes count] > 0) {
        // If only one route, just take that one
        if ([struckRoutes count] == 1) {
            self.selectedRoute = (TSRouteOption *)struckRoutes[0];
        }
        else {
            // If multiple overlapping routes, alternate if one is already selected
            BOOL previouslySelectedRouteWasStruck = NO;
            for (TSRouteOption *routeOption in struckRoutes) {
                if (self.selectedRoute == routeOption) {
                    NSUInteger selectedIndex = [struckRoutes indexOfObject:routeOption];
                    self.selectedRoute = (TSRouteOption *)struckRoutes[(selectedIndex + 1) % struckRoutes.count];
                    previouslySelectedRouteWasStruck = YES;
                    break;
                }
            }
            // Otherwise, just take the first one
            if (!previouslySelectedRouteWasStruck) {
                self.selectedRoute = (TSRouteOption *)struckRoutes[0];
            }
        }
        [self refreshOverlays];
    }
}

- (void)addRouteOverlaysToMapViewAndAnnotations {
    
    [self addRouteOverlaysToMapView];
    [self addRouteAnnotations];
}

- (void)addRouteAnnotations {
    
    for (TSRouteOption *routeOption in _routeOptions) {
        
        if (routeOption.routeTimeAnnotation == _selectedRoute.routeTimeAnnotation) {
            // skip selected route so we can add it last, on top of others
            // this handles when two routes overlap
            continue;
        }
        
        [_mapView addAnnotation:routeOption.routeTimeAnnotation];
    }
    
    if (_selectedRoute) {
        // Add last to counter possible overlap preventing display
        [_mapView addAnnotation:_selectedRoute.routeTimeAnnotation];
    }
}

- (void)addRouteOverlaysToMapView {
    
    for (TSRouteOption *routeOption in _routeOptions) {
        
        if (routeOption.route == _selectedRoute.route) {
            continue;
        }
        [_mapView addOverlay:routeOption.polyline level:MKOverlayLevelAboveRoads];
    }
    
    if (_selectedRoute.polyline) {
        [_mapView addOverlay:_selectedRoute.polyline level:MKOverlayLevelAboveRoads];
    }
}

- (void)removeRouteOverlaysAndAnnotations {
    [self removeRouteOverlays];
    [self removeAnnotations];
}

- (void)removeAnnotations {
    
    NSMutableArray *annotations = [[NSMutableArray alloc] initWithCapacity:[_routeOptions count]];
    
    for (TSRouteOption *routeOption in [NSArray arrayWithArray:_routeOptions]) {
        
        if (routeOption.routeTimeAnnotation) {
            [annotations addObject:routeOption.routeTimeAnnotation];
        }
    }
    
    [_mapView removeAnnotations:annotations];
}

- (void)removeRouteOverlays{
    NSMutableArray *overlays = [[NSMutableArray alloc] initWithCapacity:[_routes count]];
    
    if (_routeOptions.count) {
        for (TSRouteOption *routeOption in [NSArray arrayWithArray:_routeOptions]) {
            [overlays addObject:routeOption.polyline];
        }
    }
    else if (_selectedRoute.polyline) {
        [overlays addObject:_selectedRoute.polyline];
    }
    
    [_mapView removeOverlays:overlays];
}

- (void)refreshOverlays {
    [self removeRouteOverlaysAndAnnotations];
    [self addRouteOverlaysToMapViewAndAnnotations];
}


- (void)showOnlySelectedRoute {
    
    if (!_selectedRoute.polyline) {
        return;
    }
    [self removeRouteOverlaysAndAnnotations];
    
    if (_selectedRoute.polyline) {
        [_mapView addOverlay:_selectedRoute.polyline level:MKOverlayLevelAboveRoads];
    }
}


#pragma mark - Destination methods

- (void)setDestinationMapItem:(MKMapItem *)destinationMapItem {
    
    _destinationMapItem = destinationMapItem;
    _tempMapItem = destinationMapItem;
}

- (void)updateTempMapItemTransportType {
    
    if (_destinationTransportType != _destinationAnnotation.transportType) {
        [self showTempDestinationAnnotation];
    }
}

- (void)updateTempMapItemLocation:(CLLocation *)location {
    
    _tempMapItem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:location.coordinate addressDictionary:_tempMapItem.placemark.addressDictionary]];
    
    if (_destinationTransportType == _destinationAnnotation.transportType) {
        _destinationAnnotation.coordinate = location.coordinate;
    }
    else {
        [self showTempDestinationAnnotation];
    }
}


- (void)matchTempDestination {
    
    _destinationMapItem = _tempMapItem;
}


- (void)showTempDestinationAnnotation {
    
    if (_destinationAnnotation) {
        [_mapView removeAnnotation:_destinationAnnotation];
    }
    
    _destinationAnnotation = [[TSSelectedDestinationAnnotation alloc] initWithCoordinates:_tempMapItem.placemark.location.coordinate
                                                                                placeName:_tempMapItem.name
                                                                              description:_tempMapItem.placemark.addressDictionary[@"Street"]
                                                                               travelType:_destinationTransportType];
    _destinationAnnotation.title = _destinationMapItem.name;
    _destinationAnnotation.temp = YES;
    
    // Ensure we have a title so callout will always come up
    if (!_destinationAnnotation.title || [_destinationAnnotation.title isEqualToString:@""]) {
        _destinationAnnotation.title = _destinationMapItem.placemark.addressDictionary[@"Street"];
    }
    else {
        _destinationAnnotation.subtitle = _destinationMapItem.placemark.addressDictionary[@"Street"];
    }
    [_mapView addAnnotation:_destinationAnnotation];
    [_mapView selectAnnotation:_destinationAnnotation animated:YES];
}



- (void)showDestinationAnnotation {
    
    if (_destinationAnnotation) {
        
    }
    
    _destinationAnnotation = [[TSSelectedDestinationAnnotation alloc] initWithCoordinates:_destinationMapItem.placemark.location.coordinate
                                                                                placeName:_destinationMapItem.name
                                                                              description:_destinationMapItem.placemark.addressDictionary[@"Street"]
                                                                               travelType:_destinationTransportType];
    _destinationAnnotation.title = _destinationMapItem.name;
    
    // Ensure we have a title so callout will always come up
    if (!_destinationAnnotation.title || [_destinationAnnotation.title isEqualToString:@""]) {
        _destinationAnnotation.title = _destinationMapItem.placemark.addressDictionary[@"Street"];
    }
    else {
        _destinationAnnotation.subtitle = _destinationMapItem.placemark.addressDictionary[@"Street"];
    }
    [_mapView addAnnotation:_destinationAnnotation];
}

- (void)hideDestinationAnnotation {
    
    [_mapView removeAnnotation:_destinationAnnotation];
    _destinationAnnotation = nil;
}

- (void)userSelectedDestination:(MKMapItem *)mapItem forTransportType:(MKDirectionsTransportType)transportType {
    
    MKDirectionsTransportType previousType = _destinationTransportType;
    _destinationTransportType = transportType;
    
    if (_destinationMapItem == mapItem && previousType == transportType) {
        return;
    }
    
    _destinationMapItem = mapItem;
    
    [self showDestinationAnnotation];
}

- (void)removeCurrentDestinationAnnotation {
    
    if (_destinationAnnotation) {
        [_mapView removeAnnotation:_destinationAnnotation];
    }
}

- (void)centerMapOnSelectedDestination {
    [_mapView showAnnotations:@[_destinationAnnotation] animated:NO];
}

- (void)selectDestinationAnnotation {
    [_mapView selectAnnotation:_destinationAnnotation animated:YES];
}


- (void)showTempDestinationAndRoute {
    
    [self getRoutesForDestination:^(TSRouteOption *bestRoute, NSError *error) {
        
    }];
}

- (void)calculateETAForSelectedDestination:(void (^)(NSTimeInterval expectedTravelTime))completion {
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    [request setSource:[MKMapItem mapItemForCurrentLocation]];
    [request setDestination:_destinationMapItem];
    [request setTransportType:_destinationTransportType];
    [request setRequestsAlternateRoutes:YES];
    
    if (_directions.isCalculating) {
        [_directions cancel];
    }
    
    _directions = [[MKDirections alloc] initWithRequest:request];
    [_directions calculateETAWithCompletionHandler:^(MKETAResponse *response, NSError *error) {
        
        if (!error) {
            NSLog(@"%@", response);
            completion(response.expectedTravelTime);
        }
        else {
            NSLog(@"%@", error);
            // May have gotten an error due to attempting walking directions over too far
            // a distance, retry with 'Any'.
            if ((error.code == MKErrorPlacemarkNotFound || error.code == MKErrorDirectionsNotFound) && _destinationTransportType == MKDirectionsTransportTypeWalking) {
                NSLog(@"Error with walking directions, trying again with 'Any'");
                _destinationTransportType = MKDirectionsTransportTypeAny;
                [self calculateETAForSelectedDestination:completion];
            }
        }
    }];
}


- (void)calculateEtaAndDistanceForSelectedDestination:(void (^)(NSTimeInterval expectedTravelTime, CLLocationDistance distance))completion {
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    [request setSource:[MKMapItem mapItemForCurrentLocation]];
    [request setDestination:_destinationMapItem];
    [request setTransportType:_destinationTransportType];
    [request setRequestsAlternateRoutes:NO];
    
    if (_directions.isCalculating) {
        [_directions cancel];
    }
    
    _directions = [[MKDirections alloc] initWithRequest:request];
    [_directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        
        if (!error && response.routes.count) {
            NSLog(@"%@", response);
            [self showDestinationAnnotation];
            self.routes = response.routes;
            MKRoute *route = [response.routes firstObject];
            completion(route.expectedTravelTime, route.distance);
        }
        else {
            NSLog(@"%@", error);
            // May have gotten an error due to attempting walking directions over too far
            // a distance, retry with 'Any'.
            if ((error.code == MKErrorPlacemarkNotFound || error.code == MKErrorDirectionsNotFound) && _destinationTransportType == MKDirectionsTransportTypeWalking) {
                NSLog(@"Error with walking directions, trying again with 'Any'");
                _destinationTransportType = MKDirectionsTransportTypeAny;
                [self calculateEtaAndDistanceForSelectedDestination:completion];
            }
            else {
                completion(0, 0);
            }
        }
    }];
}

- (void)showAnnotationsWithPadding:(NSArray *)annotations {
    
    MKMapRect zoomRect = MKMapRectNull;
    for (id <MKAnnotation> annotation in annotations) {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }
    [_mapView setVisibleMapRect:zoomRect edgePadding:UIEdgeInsetsMake(130, 60, 30, 60) animated:YES];
}



- (void)getRoutesForDestination:(void (^)(TSRouteOption *bestRoute, NSError *error))completion {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    [request setSource:[MKMapItem mapItemForCurrentLocation]];
    [request setDestination:_destinationMapItem];
    [request setTransportType:_destinationTransportType]; // This can be limited to automobile and walking directions.
    [request setRequestsAlternateRoutes:YES]; // Gives you several route options.
    
    if (_directions.isCalculating) {
        [_directions cancel];
    }
    
    _selectedRoute = nil;
    [self removeRouteOverlaysAndAnnotations];
    [self hideDestinationAnnotation];
    
    _directions = [[MKDirections alloc] initWithRequest:request];
    [_directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if (!error) {
            [self showTempDestinationAnnotation];
            self.routes = response.routes;
            self.selectedRoute = [self.routeOptions firstObject];
            [self addRouteOverlaysToMapViewAndAnnotations];
            
            if (completion) {
                completion(_selectedRoute, nil);
            }
        }
        else {
            if (completion) {
                completion(nil, error);
            }
        }
    }];
}
        
- (void)cancelSearch {
    
    [_directions cancel];
}

@end
