//
//  TSRouteManager.m
//  TapShield
//
//  Created by Adam Share on 4/2/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSRouteManager.h"
#import "TSLocationController.h"

@interface TSRouteManager ()

@property (nonatomic, strong) NSArray *routes;
@property (nonatomic, strong) MKMapItem *tempMapItem;
@property (nonatomic, strong) NSArray *routeOverlays;


@end


@implementation TSRouteManager

- (instancetype)initWithMapView:(TSMapView *)mapView
{
    self = [super init];
    if (self) {
        self.mapView = mapView;
        self.shouldCancel = NO;
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
    
    if (routeOptions) {
        [self creatRouteAnnotations];
    }
}

- (void)creatRouteAnnotations {
    
    if (!_mapView.userLocationAnnotation || !_destinationAnnotation) {
        return;
    }
    
    NSMutableArray *annotations = [[NSMutableArray alloc] initWithArray:@[_mapView.userLocationAnnotation, _destinationAnnotation]];
    
    if (_routeOptions.count > 1) {
        for (TSRouteOption *routeOption in _routeOptions) {
            
            [routeOption findUniqueMapPointComparingRoutes:_routes completion:^(MKMapPoint uniquePointFromSet) {
                routeOption.routeTimeAnnotation = [[TSRouteTimeAnnotation alloc] initWithCoordinates:MKCoordinateForMapPoint(uniquePointFromSet) placeName:[TSUtilities formattedStringForDuration:routeOption.expectedTravelTime] description:@""];
                [annotations addObject:routeOption.routeTimeAnnotation];
            }];
        }
    }
    
    _routingAnnotations = annotations;
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
    
    _selectedTravelTime = _selectedRoute.expectedTravelTime;
    
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
            if (_selectedRoute != (TSRouteOption *)struckRoutes[0]) {
                self.selectedRoute = (TSRouteOption *)struckRoutes[0];
            }
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

- (void)addRouteOverlaysAndAnnotations {
    
    [self addRouteOverlaysToMapView];
    [self addRouteAnnotations];
    [self showSafeZoneOverlay];
}

- (void)addRouteAnnotations {
    
    if (_routeOptions.count <= 1) {
        return;
    }
    
    if (_shouldCancel) {
        return;
    }
    
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
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:3];
    
    [self removeRouteOverlaysAndAnnotations];
    
    if (_shouldCancel) {
        return;
    }
    
    for (TSRouteOption *routeOption in _routeOptions) {
        
        if (routeOption.route == _selectedRoute.route) {
            continue;
        }
        [_mapView addOverlay:routeOption.polyline level:MKOverlayLevelAboveRoads];
        [mutableArray addObject:routeOption.polyline];
    }
    
    if (_selectedRoute.polyline) {
        [_mapView addOverlay:_selectedRoute.polyline level:MKOverlayLevelAboveRoads];
        [mutableArray addObject:_selectedRoute.polyline];
    }
    
    _routeOverlays = mutableArray;
}


- (void)addOnlySelectedRouteOverlaysToMapView {
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:3];
    
    [self removeRouteOverlaysAndAnnotations];
    
    if (_shouldCancel) {
        return;
    }
    
    if (_selectedRoute.polyline) {
        [_mapView addOverlay:_selectedRoute.polyline level:MKOverlayLevelAboveRoads];
        [mutableArray addObject:_selectedRoute.polyline];
    }
    
    _routeOverlays = mutableArray;
    
    [self showSafeZoneOverlay];
}

- (void)clearRouteAndMapData {
    
    [self removeRouteOverlaysAndAnnotations];
    [self hideDestinationAnnotation];
    [self hideSafeZoneOverlay];
    
    _destinationAnnotation = nil;
    _safeZoneOverlay = nil;
    _destinationMapItem = nil;
    _tempMapItem = nil;
    _routes = nil;
    _selectedRoute = nil;
    _routeOptions = nil;
    _routeOverlays = nil;
    _routingAnnotations = nil;
}

- (void)showSafeZoneOverlay {
    
    if (_safeZoneOverlay) {
        [self hideSafeZoneOverlay];
    }
    
    _safeZoneOverlay = [TSSafeZoneCircleOverlay circleWithCenterCoordinate:_destinationAnnotation.coordinate radius:30];
    _safeZoneOverlay.mapView = _mapView;
    [_mapView addOverlay:_safeZoneOverlay level:MKOverlayLevelAboveRoads];
}

- (void)hideSafeZoneOverlay {
    
    [_mapView removeOverlay:_safeZoneOverlay];
    
    _safeZoneOverlay.inside = NO;
    _safeZoneOverlay = nil;
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
    
    [_mapView removeOverlays:_routeOverlays];
}

- (void)refreshOverlays {
    [self removeRouteOverlaysAndAnnotations];
    [self addRouteOverlaysAndAnnotations];
}


- (void)showOnlySelectedRoute {
    
    if (!_selectedRoute.polyline) {
        return;
    }
    [self removeRouteOverlaysAndAnnotations];
    
    if (_selectedRoute.polyline) {
        
        [self removeRouteOverlaysAndAnnotations];
        
        if (_shouldCancel) {
            return;
        }
        [_mapView addOverlay:_selectedRoute.polyline level:MKOverlayLevelAboveRoads];
        _routeOverlays = @[_selectedRoute.polyline];
    }
}


#pragma mark - Destination methods

- (void)setDestinationMapItem:(MKMapItem *)destinationMapItem {
    
    _destinationMapItem = destinationMapItem;
    _tempMapItem = destinationMapItem;
}

- (void)updateTempMapItemTransportType {
    
    if (_destinationTransportType != _destinationAnnotation.transportType) {
        [self showTempDestinationAnnotationSelected:NO];
    }
}

- (void)updateTempMapItemLocation:(CLLocation *)location {
    
    _tempMapItem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:location.coordinate addressDictionary:_tempMapItem.placemark.addressDictionary]];
    
    if (_destinationTransportType == _destinationAnnotation.transportType) {
        _destinationAnnotation.coordinate = location.coordinate;
    }
    else {
        [self showTempDestinationAnnotationSelected:YES];
    }
    
    _destinationAnnotation.title = [NSString stringWithFormat:@"%@", [TSUtilities formattedDescriptiveStringForDuration:_selectedRoute.expectedTravelTime]];
    [self showSafeZoneOverlay];
}


- (void)matchTempDestination {
    
    _destinationMapItem = _tempMapItem;
}


- (void)showTempDestinationAnnotationSelected:(BOOL)selected {
    
    if (_destinationAnnotation) {
        [_mapView removeAnnotation:_destinationAnnotation];
    }
    
    if (_shouldCancel) {
        return;
    }
    
    _destinationAnnotation = [[TSSelectedDestinationAnnotation alloc] initWithCoordinates:_tempMapItem.placemark.location.coordinate
                                                                                placeName:[NSString stringWithFormat:@"%@", [TSUtilities formattedDescriptiveStringForDuration:_selectedRoute.expectedTravelTime]]
                                                                              description:nil
                                                                               travelType:_destinationTransportType];
    _destinationAnnotation.temp = YES;
    [_mapView addAnnotation:_destinationAnnotation];
    
    [self showSafeZoneOverlay];
    
    if (selected) {
        [self selectTempAnnotation];
    }
}



- (void)showDestinationAnnotation {
    
    if (_destinationAnnotation) {
        [_mapView removeAnnotation:_destinationAnnotation];
    }
    
    if (_shouldCancel) {
        return;
    }
    
    
    _destinationAnnotation = [[TSSelectedDestinationAnnotation alloc] initWithCoordinates:_destinationMapItem.placemark.location.coordinate
                                                                                placeName:_destinationMapItem.name
                                                                              description:[TSUtilities formattedAddressSecondLine:_destinationMapItem.placemark.addressDictionary]
                                                                               travelType:_destinationTransportType];
    
    // Ensure we have a title so callout will always come up
    if (!_destinationAnnotation.title || [_destinationAnnotation.title isEqualToString:@""]) {
        _destinationAnnotation.title = _destinationMapItem.placemark.addressDictionary[(__bridge NSString *)kABPersonAddressStreetKey];
    }
    else if (![_destinationAnnotation.title isEqualToString:_destinationMapItem.placemark.addressDictionary[(__bridge NSString *)kABPersonAddressStreetKey]]) {
        _destinationAnnotation.subtitle = _destinationMapItem.placemark.addressDictionary[(__bridge NSString *)kABPersonAddressStreetKey];
    }
    [_mapView addAnnotation:_destinationAnnotation];
    
    [self showSafeZoneOverlay];
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

- (void)centerMapOnSelectedDestination {
    
    [_mapView showAnnotations:@[_destinationAnnotation] animated:NO];
    [_mapView setCenterCoordinate:_destinationMapItem.placemark.coordinate animated:NO];
}

- (void)selectDestinationAnnotation {
    [_mapView selectAnnotation:_destinationAnnotation animated:YES];
}

- (void)calculateETAForSelectedDestination:(void (^)(NSTimeInterval expectedTravelTime))completion {
    
    __weak __typeof(self)weakSelf = self;
    [[TSLocationController sharedLocationController] startStandardLocationUpdates:^(CLLocation *location) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
        [request setSource:[MKMapItem mapItemForCurrentLocation]];
        [request setDestination:strongSelf.destinationMapItem];
        [request setTransportType:strongSelf.destinationTransportType];
        [request setRequestsAlternateRoutes:YES];
        
        if (strongSelf.directions.isCalculating) {
            [strongSelf.directions cancel];
        }
        
        strongSelf.directions = [[MKDirections alloc] initWithRequest:request];
        [strongSelf.directions calculateETAWithCompletionHandler:^(MKETAResponse *response, NSError *error) {
            
            if (!error) {
                completion(response.expectedTravelTime);
            }
            else {
                // May have gotten an error due to attempting walking directions over too far
                // a distance, retry with 'Any'.
                if ((error.code == MKErrorPlacemarkNotFound || error.code == MKErrorDirectionsNotFound) && strongSelf.destinationTransportType == MKDirectionsTransportTypeWalking) {
                    strongSelf.destinationTransportType = MKDirectionsTransportTypeAny;
                    [strongSelf calculateETAForSelectedDestination:completion];
                }
            }
        }];
        
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

- (void)getAndShowBestRoute {
    
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
            self.routes = response.routes;
            self.selectedRoute = [self.routeOptions firstObject];
            [self addOnlySelectedRouteOverlaysToMapView];
        }
        else {
            NSLog(@"%@", error);
            // May have gotten an error due to attempting walking directions over too far
            // a distance, retry with 'Any'.
            if ((error.code == MKErrorPlacemarkNotFound || error.code == MKErrorDirectionsNotFound) && _destinationTransportType == MKDirectionsTransportTypeWalking) {
                NSLog(@"Error with walking directions, trying again with 'Any'");
                _destinationTransportType = MKDirectionsTransportTypeAny;
            }
        }
    }];
}

- (void)showAllRouteAnnotations {
    
    [self showDestinationAnnotation];
    [self showWithPaddingAnnotations:_routingAnnotations overlays:_routeOptions];
}

- (void)showActiveEntourageSession {
    
    if (!_mapView.userLocationAnnotation || !_destinationAnnotation) {
        return;
    }
    
    NSArray *overlays;
    if (_selectedRoute) {
        overlays = @[_selectedRoute];
    }
    
    [self showWithBottomMapButtonPaddingAnnotations:@[_mapView.userLocationAnnotation, _destinationAnnotation] overlays:overlays];
}

- (void)showWithPaddingAnnotations:(NSArray *)annotations overlays:(NSArray *)overlays {
    
    MKMapRect zoomRect = MKMapRectNull;
    for (id <MKAnnotation> annotation in annotations) {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }
    
    for (TSRouteOption *option in overlays) {
        zoomRect = MKMapRectUnion(zoomRect, option.polyline.boundingMapRect);
    }
    
    [_mapView setVisibleMapRect:zoomRect edgePadding:UIEdgeInsetsMake(130, 60, 30, 60) animated:YES];
}


- (void)showWithBottomMapButtonPaddingAnnotations:(NSArray *)annotations overlays:(NSArray *)overlays {
    
    MKMapRect zoomRect = MKMapRectNull;
    for (id <MKAnnotation> annotation in annotations) {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }
    
    for (TSRouteOption *option in overlays) {
        zoomRect = MKMapRectUnion(zoomRect, option.polyline.boundingMapRect);
    }
    
    [_mapView setVisibleMapRect:zoomRect edgePadding:UIEdgeInsetsMake(130, 60, 120, 60) animated:YES];
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
    
    [self removeRouteOverlaysAndAnnotations];
    [self hideDestinationAnnotation];
    [self hideSafeZoneOverlay];
    _selectedRoute = nil;
    self.routes = nil;
    
    _directions = [[MKDirections alloc] initWithRequest:request];
    [_directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if (!error) {
            [self showTempDestinationAnnotationSelected:YES];
            self.routes = response.routes;
            self.selectedRoute = [self.routeOptions firstObject];
            _destinationAnnotation.title = [NSString stringWithFormat:@"%@", [TSUtilities formattedDescriptiveStringForDuration:_selectedRoute.expectedTravelTime]];
            [self addOnlySelectedRouteOverlaysToMapView];
            
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


- (void)selectTempAnnotation {
    
    [_mapView.userLocationAnnotationView setEnabled:NO];
    self.destinationAnnotation.shouldStaySelected = YES;
    [_mapView selectAnnotation:self.destinationAnnotation animated:YES];
}


- (void)deselectTempAnnotation {
    
    [_mapView.userLocationAnnotationView setEnabled:YES];
    self.destinationAnnotation.shouldStaySelected = NO;
    [_mapView deselectAnnotation:self.destinationAnnotation animated:YES];
}

@end
