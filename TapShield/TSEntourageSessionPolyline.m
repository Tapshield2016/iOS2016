//
//  TSEntourageSessionPolyline.m
//  TapShield
//
//  Created by Adam Share on 11/16/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSEntourageSessionPolyline.h"
#import "TSColorPalette.h"

@implementation TSEntourageSessionPolyline


- (MKPolylineRenderer *)renderer {
    MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithOverlay:self];
    [renderer setLineWidth:4.0];
    [renderer setStrokeColor:[[TSColorPalette tapshieldBlue] colorWithAlphaComponent:0.4]];
    
    return renderer;
}

@end
