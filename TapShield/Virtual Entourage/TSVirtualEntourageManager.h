//
//  TSVirtualEntourageManager.h
//  TapShield
//
//  Created by Adam Share on 4/2/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface TSVirtualEntourageManager : NSObject

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) NSArray *routes;
@property (nonatomic, strong) MKRoute *selectedRoute;

- (instancetype)initWithMapView:(MKMapView *)mapView;

- (void)selectRouteClosestTo:(MKMapPoint)mapPoint;
- (void)addRouteOverlaysToMapView;
- (void)removeRouteOverlays;

@end
