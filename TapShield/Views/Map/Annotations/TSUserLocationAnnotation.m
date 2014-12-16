//
//  TSUserLocationAnnotation.m
//  TapShield
//
//  Created by Ben Boyd on 1/28/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSUserLocationAnnotation.h"
#import "TSUserAnnotationView.h"
#import "NSDate+Utilities.h"
#import "TSMapView.h"

@implementation TSUserLocationAnnotation

- (instancetype)initWithLocation:(CLLocation *)location {
    
    self = [super initWithCoordinates:location.coordinate placeName:nil description:nil];
    if (!self) {
        return self;
    }
    
    self.location = location;
    
    return self;
}

- (void)setLocation:(CLLocation *)location {
    
    _location = location;
    
    self.annotationView.animatedOverlay.annotationAnimating = YES;
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.annotationView.mapView removeAccuracyCircleOverlay];
        
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionCurveEaseInOut|UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
            self.coordinate = location.coordinate;
        } completion:^(BOOL finished) {
            self.annotationView.animatedOverlay.annotationAnimating = NO;
            [self.annotationView updateAnimatedViewAt:_location];
            [self.annotationView.mapView updateAccuracyCircleWithLocation:_location];
        }];
    }];
}

@end
