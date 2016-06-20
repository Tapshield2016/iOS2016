//
//  TSEntourageSessionPolyline.m
//  TapShield
//
//  Created by Adam Share on 11/16/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSEntourageSessionPolylineOverlay.h"
#import "TSColorPalette.h"

@implementation TSEntourageSessionPolylineOverlay


- (TSEntourageSessionPolylineRenderer *)renderer {
    TSEntourageSessionPolylineRenderer *renderer = [[TSEntourageSessionPolylineRenderer alloc] initWithOverlay:self];
    [renderer setStrokeColor:[TSColorPalette tapshieldBlue]];
    
    return renderer;
}

@end



@implementation TSEntourageSessionPolylineRenderer

- (void)applyStrokePropertiesToContext:(CGContextRef)context atZoomScale:(MKZoomScale)zoomScale {
    
    [super applyStrokePropertiesToContext:context atZoomScale:zoomScale];
    
    if (self.strokeColor) {
        CGContextSetStrokeColorWithColor(context, [self.strokeColor colorWithAlphaComponent:0.8].CGColor);
    }
    else {
        CGContextSetStrokeColorWithColor(context, [[TSColorPalette tapshieldBlue] colorWithAlphaComponent:0.8].CGColor);
    }
    
    if (!self.selectedRoute) {
        CGContextSetLineWidth(context, MKRoadWidthAtZoomScale(zoomScale)*1.5);
    }
    else {
        CGContextSetLineWidth(context, MKRoadWidthAtZoomScale(zoomScale)*2.0);
    }
}

@end