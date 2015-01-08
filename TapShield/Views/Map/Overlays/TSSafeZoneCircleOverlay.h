//
//  TSSafeAreaCircle.h
//  TapShield
//
//  Created by Adam Share on 12/16/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseCircleOverlay.h"


@interface TSSafeCircleRenderer : MKCircleRenderer

@end


@interface TSSafeZoneCircleOverlay : TSBaseCircleOverlay

@property (assign, nonatomic) BOOL inside;

@property (strong, nonatomic) NSTimer *timer;

@property (nonatomic, assign) NSUInteger countdown;

@property (nonatomic, strong) TSSafeCircleRenderer *renderer;

@property (nonatomic, weak) MKMapView *mapView;

@end