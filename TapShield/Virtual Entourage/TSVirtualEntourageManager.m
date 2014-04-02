//
//  TSVirtualEntourageManager.m
//  TapShield
//
//  Created by Adam Share on 4/2/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSVirtualEntourageManager.h"

@implementation TSVirtualEntourageManager

- (instancetype)initWithMapView:(MKMapView *)mapView
{
    self = [super init];
    if (self) {
        self.mapView = mapView;
    }
    return self;
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
                    
                    for (MKRoute *route in _routes) {
                        if (route.polyline == poly) {
                            [struckRoutes addObject:route];
                        }
                    }
                }
                else if (distanceToPolyline == shortestDistance) {
                    for (MKRoute *route in _routes) {
                        if (route.polyline == poly) {
                            [struckRoutes addObject:route];
                        }
                    }
                }
            }
        }
    }
    [self setSelectedRouteFromStruckRoutes:struckRoutes];
}

- (void)setSelectedRouteFromStruckRoutes:(NSMutableArray *)struckRoutes {
    
    if ([struckRoutes count] > 0) {
        // If only one route, just take that one
        if ([struckRoutes count] == 1) {
            _selectedRoute = struckRoutes[0];
        }
        else {
            // If multiple overlapping routes, alternate if one is already selected
            BOOL previouslySelectedRouteWasStruck = NO;
            for (MKRoute *route in struckRoutes) {
                if (_selectedRoute == route) {
                    NSUInteger selectedIndex = [struckRoutes indexOfObject:route];
                    _selectedRoute = struckRoutes[(selectedIndex + 1) % struckRoutes.count];
                    previouslySelectedRouteWasStruck = YES;
                    break;
                }
            }
            // Otherwise, just take the first one
            if (!previouslySelectedRouteWasStruck) {
                _selectedRoute = struckRoutes[0];
            }
        }
        NSLog(@"%@ selected", _selectedRoute.name);
        [self refreshOverlays];
    }
}

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


- (void)addRouteOverlaysToMapView {
    
    //    if (_routes.count > 1) {
    //        NSMutableArray *annotationCoordinates = [[NSMutableArray alloc] initWithCapacity:6];
    //
    //        for (MKRoute *route in _routes) {
    //            NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithArray:_routes];
    //            [mutableArray removeObjectsInArray:@[route]];
    //            route.uniquePoint = [self findUniqueMapPointFrom:route.polyline comparing:mutableArray];
    //
    //            route.routeTimeAnnotation = [[TSRouteTimeAnnotation alloc] initWithCoordinates:MKCoordinateForMapPoint(route.uniquePoint) placeName:[TSUtilities formattedStringForDuration:route.expectedTravelTime] description:@""];
    //            [_mapView addAnnotation:route.routeTimeAnnotation];
    //        }
    //    }
    
    for (MKRoute *route in _routes) {
        
        if (route == _selectedRoute) {
            // skip selected route so we can add it last, on top of others
            // this handles when two routes overlap
            continue;
        }
        [_mapView addOverlay:[route polyline] level:MKOverlayLevelAboveRoads]; // Draws the route above roads, but below labels.
        // You can also get turn-by-turn steps, distance, advisory notices, ETA, etc by accessing various route properties.
        //        NSLog(@"%f minutes", ceil(route.expectedTravelTime / 60));
        //        NSLog(@"%.02f miles", route.distance * 0.000621371);
    }
    
    if (_selectedRoute) {
        // Add last to counter possible overlap preventing display
        [_mapView addOverlay:[_selectedRoute polyline] level:MKOverlayLevelAboveRoads];
    }
}

- (void)removeRouteOverlays {
    NSMutableArray *overlays = [[NSMutableArray alloc] initWithCapacity:[_routes count]];
    
    for (MKRoute *route in _routes) {
        [overlays addObject:route.polyline];
    }
    
    [_mapView removeOverlays:overlays];
}

- (void)refreshOverlays {
    [self removeRouteOverlays];
    [self addRouteOverlaysToMapView];
}


@end
