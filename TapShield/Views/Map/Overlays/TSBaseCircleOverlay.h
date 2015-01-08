//
//  TSBaseOverlay.h
//  TapShield
//
//  Created by Adam Share on 12/16/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface TSBaseCircleOverlay : MKCircle

- (MKOverlayRenderer *)renderer;

@end
