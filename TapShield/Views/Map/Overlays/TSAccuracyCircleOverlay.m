//
//  TSAccuracyCircleOverlay.m
//  TapShield
//
//  Created by Adam Share on 12/17/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSAccuracyCircleOverlay.h"
#import "TSJavelinAPIClient.h"
#import "TSAlertManager.h"

@implementation TSAccuracyCircleOverlay

- (MKOverlayRenderer *)renderer {
    
    MKCircleRenderer *circleRenderer = [[MKCircleRenderer alloc] initWithCircle:self];
    
    UIColor *color = [[TSColorPalette tapshieldBlue] colorWithAlphaComponent:0.1f];
    if ([TSJavelinAPIClient sharedClient].isStillActiveAlert && [TSAlertManager sharedManager].type != kAlertTypeChat) {
        color = [[TSColorPalette alertRed] colorWithAlphaComponent:0.1f];
    }
    
    circleRenderer.lineWidth = 1.0;
    circleRenderer.strokeColor = color;
    circleRenderer.fillColor = color;
    
    return circleRenderer;
}

@end
