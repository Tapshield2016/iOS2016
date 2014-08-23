//
//  TSBoundariesOverlay.h
//  TapShield
//
//  Created by Adam Share on 7/15/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "TSJavelinAPIAgency.h"
#import "TSJavelinAPIRegion.h"

@interface TSBoundariesOverlay : MKPolygonRenderer

- (instancetype)initWithPolygon:(MKPolygon *)polygon agency:(TSJavelinAPIAgency *)agency region:(TSJavelinAPIRegion *)region;

@property (nonatomic, strong) UIImage *image;

@end
