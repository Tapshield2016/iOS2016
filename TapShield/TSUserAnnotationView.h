//
//  TSUserAnnotationView.h
//  TapShield
//
//  Created by Adam Share on 4/3/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseAnnotationView.h"
#import "TSAnimatedAccuracyCircle.h"

@class TSMapView;

@interface TSUserAnnotationView : TSBaseAnnotationView

@property (nonatomic, weak) TSMapView *mapView;

- (void)updateAnimatedViewAt:(CLLocation *)location;

@property (nonatomic, strong) TSAnimatedAccuracyCircle *animatedOverlay;

- (void)updateAnimatedUserAnnotation;

@end
