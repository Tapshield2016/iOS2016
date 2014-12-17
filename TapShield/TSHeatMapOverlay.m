//
//  TSHeatMapOverlay.m
//  TapShield
//
//  Created by Adam Share on 7/10/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSHeatMapOverlay.h"
#import "TSColorPalette.h"

@implementation TSHeatMapOverlay

- (MKCircleRenderer *)renderer {
    
    MKCircleRenderer *circleRenderer = [[MKCircleRenderer alloc] initWithCircle:self];
    
    circleRenderer.lineWidth = 1.0;
    circleRenderer.strokeColor = [[TSColorPalette alertRed] colorWithAlphaComponent:0.2f];
    circleRenderer.fillColor = [[TSColorPalette alertRed] colorWithAlphaComponent:0.2f];
        
    return circleRenderer;
}

@end
