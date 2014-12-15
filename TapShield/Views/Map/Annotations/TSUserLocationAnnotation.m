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
    
    [self.annotationView updateAnimatedViewAt:location];
}

@end
