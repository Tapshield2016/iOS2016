//
//  TSHeatMapOverlay.m
//  TapShield
//
//  Created by Adam Share on 7/10/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSHeatMapOverlay.h"

@implementation TSHeatMapOverlay

+ (TSHeatMapOverlay *)circleWithCenterCoordinate:(CLLocationCoordinate2D)coord
                                          radius:(CLLocationDistance)radius {
    
    TSHeatMapOverlay *overlay = [[TSHeatMapOverlay alloc] init];
    overlay.coordinate = coord;
    overlay.radius = radius;
    
    return overlay;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)setRadius:(CLLocationDistance)radius {
    
    _radius = radius;
}

@end
