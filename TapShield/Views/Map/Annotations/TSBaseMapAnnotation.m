//
//  TSBaseMapAnnotation.m
//  TapShield
//
//  Created by Ben Boyd on 2/18/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseMapAnnotation.h"

@implementation TSBaseMapAnnotation

- (id)initWithCoordinates:(CLLocationCoordinate2D)location placeName:(NSString *)placeName description:(NSString *)description {
    self = [super init];
    if (self != nil) {
        _coordinate = location;
        _title = placeName;
        _subtitle = description;
    }
    return self;
}

@end
