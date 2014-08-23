//
//  TSHeatMapOverlay.h
//  TapShield
//
//  Created by Adam Share on 7/10/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface TSHeatMapOverlay : MKShape <MKOverlay>

+ (TSHeatMapOverlay *)circleWithCenterCoordinate:(CLLocationCoordinate2D)coord
                                  radius:(CLLocationDistance)radius;

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) CLLocationDistance radius;
@property (nonatomic, readonly) MKMapRect boundingMapRect;

@end
