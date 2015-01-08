//
//  TSBaseOverlay.m
//  TapShield
//
//  Created by Adam Share on 12/16/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseCircleOverlay.h"

@implementation TSBaseCircleOverlay

- (MKOverlayRenderer *)renderer {
    
    MKOverlayRenderer *renderer = [[MKOverlayRenderer alloc] initWithOverlay:self];
    
    return renderer;
}

@end
