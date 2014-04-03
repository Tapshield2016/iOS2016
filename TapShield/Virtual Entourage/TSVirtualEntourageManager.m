//
//  TSVirtualEntourageManager.m
//  TapShield
//
//  Created by Adam Share on 4/2/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSVirtualEntourageManager.h"
#import "TSUtilities.h"

@implementation TSVirtualEntourageManager

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
    
    NSMutableArray *annotationCoordinates = [[NSMutableArray alloc] initWithArray:@[_mapView.userLocationAnnotation, _destinationAnnotation]];
    
    NSMutableArray *mutableRouteOptions = [[NSMutableArray alloc] initWithCapacity:4];
    
    for (MKRoute *route in _routes) {
        
        TSRouteOption *routeOption = [[TSRouteOption alloc] initWithRoute:route];
        MKMapPoint uniquePoint = [routeOption findUniqueMapPointComparingRoutes:_routes];
        
        routeOption.routeTimeAnnotation = [[TSRouteTimeAnnotation alloc] initWithCoordinates:MKCoordinateForMapPoint(uniquePoint) placeName:[TSUtilities formattedStringForDuration:route.expectedTravelTime] description:@""];
        
        [annotationCoordinates addObject:routeOption.routeTimeAnnotation];
        [mutableRouteOptions addObject:routeOption];
    }
    
    self.routeOptions = mutableRouteOptions;
    _routingAnnotations = annotationCoordinates;
}

- (void)setRouteOptions:(NSArray *)routeOptions {
    
    _routeOptions = routeOptions;
    
    for (TSRouteOption *routeOption in _routeOptions) {
        
        [routeOption.routeTimeAnnotation setImageDirectionRelativeToStartingPoint:_mapView.userLocationAnnotation endingPoint:_destinationAnnotation];
        
        NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:_routeOptions];
        [mutableArray removeObject:routeOption];
        
        [routeOption.routeTimeAnnotation setImageDirectionRelativeToRouteOptions:mutableArray];
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
                
                double distanceToPolyline = [self distanceOfPoint:mapPoint toPoly:poly];
                if (distanceToPolyline < shortestDistance) {
                    
                    //Reset array to only include closest polyline
                    struckRoutes = [[NSMutableArray alloc] initWithCapacity:4];
                    shortestDistance = distanceToPolyline;
                    
                    for (TSRouteOption *routeOption in _routeOptions) {
                        if (routeOption.route.polyline == poly) {
                            [struckRoutes addObject:routeOption];
                        }
                    }
                }
                else if (distanceToPolyline == shortestDistance) {
                    for (TSRouteOption *routeOption in _routeOptions) {
                        if (routeOption.route.polyline == poly) {
                            [struckRoutes addObject:routeOption];
                        }
                    }
                }
            }
        }
    }
    [self setSelectedRouteFromStruckRoutes:struckRoutes];
}

- (void)setSelectedRouteFromStruckRoutes:(NSMutableArray *)struckRoutes {
    
    TSRouteTimeAnnotation *annotation;
    
    if ([struckRoutes count] > 0) {
        // If only one route, just take that one
        if ([struckRoutes count] == 1) {
            self.selectedRoute = (TSRouteOption *)struckRoutes[0];
            annotation = ((TSRouteOption *)struckRoutes[0]).routeTimeAnnotation;
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
        NSLog(@"%@ selected", _selectedRoute.route.name);
        [self refreshOverlays];
    }
}

- (void)addRouteOverlaysToMapViewAndAnnotations {
    
    [self addRouteOverlaysToMapView];
    
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
            // skip selected route so we can add it last, on top of others
            // this handles when two routes overlap
            continue;
        }
        [_mapView addOverlay:[routeOption.route polyline] level:MKOverlayLevelAboveRoads]; // Draws the route above roads, but below labels.
        // You can also get turn-by-turn steps, distance, advisory notices, ETA, etc by accessing various route properties.
        //        NSLog(@"%f minutes", ceil(route.expectedTravelTime / 60));
        //        NSLog(@"%.02f miles", route.distance * 0.000621371);
    }
    
    if (_selectedRoute) {
        // Add last to counter possible overlap preventing display
        [_mapView addOverlay:[_selectedRoute.route polyline] level:MKOverlayLevelAboveRoads];
    }
}

- (void)removeRouteOverlaysAndAnnotations {
    [self removeRouteOverlays];
    [self removeAnnotations];
}

- (void)removeAnnotations {
    
    NSMutableArray *annotations = [[NSMutableArray alloc] initWithCapacity:[_routingAnnotations count]];
    
    for (TSRouteOption *routeOption in _routeOptions) {
        [annotations addObject:routeOption.routeTimeAnnotation];
    }
    
    [_mapView removeAnnotations:annotations];
}

- (void)removeRouteOverlays{
    NSMutableArray *overlays = [[NSMutableArray alloc] initWithCapacity:[_routes count]];
    
    for (TSRouteOption *routeOption in _routeOptions) {
        [overlays addObject:routeOption.route.polyline];
    }
    
    [_mapView removeOverlays:overlays];
}

- (void)refreshOverlays {
    [self removeRouteOverlaysAndAnnotations];
    [self addRouteOverlaysToMapViewAndAnnotations];
}


#pragma mark - Destination methods

- (void)userSelectedDestination:(MKMapItem *)mapItem forTransportType:(MKDirectionsTransportType)transportType {
    
    _destinationTransportType = transportType;
    
    if (_destinationMapItem == mapItem) {
        return;
    }
    
    _destinationMapItem = mapItem;
    
    if (_destinationAnnotation) {
        [_mapView removeAnnotation:_destinationAnnotation];
    }
    
    _destinationAnnotation = [[TSSelectedDestinationAnnotation alloc] initWithCoordinates:_destinationMapItem.placemark.location.coordinate
                                                                                placeName:_destinationMapItem.name
                                                                              description:_destinationMapItem.placemark.addressDictionary[@"Street"]];
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


#pragma mark - Distance Methods 

- (double)distanceOfPoint:(MKMapPoint)pt toPoly:(MKPolyline *)poly {
    double distance = MAXFLOAT;
    for (int n = 0; n < poly.pointCount - 1; n++) {
        
        MKMapPoint ptA = poly.points[n];
        MKMapPoint ptB = poly.points[n + 1];
        
        double xDelta = ptB.x - ptA.x;
        double yDelta = ptB.y - ptA.y;
        
        if (xDelta == 0.0 && yDelta == 0.0) {
            
            // Points must not be equal
            continue;
        }
        
        double u = ((pt.x - ptA.x) * xDelta + (pt.y - ptA.y) * yDelta) / (xDelta * xDelta + yDelta * yDelta);
        MKMapPoint ptClosest;
        if (u < 0.0) {
            
            ptClosest = ptA;
        }
        else if (u > 1.0) {
            
            ptClosest = ptB;
        }
        else {
            
            ptClosest = MKMapPointMake(ptA.x + u * xDelta, ptA.y + u * yDelta);
        }
        
        distance = MIN(distance, MKMetersBetweenMapPoints(ptClosest, pt));
    }
    
    return distance;
}


@end
