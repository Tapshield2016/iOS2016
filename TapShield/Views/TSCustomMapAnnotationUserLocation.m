//
//  TSCustomMapAnnotationUserLocation.m
//  TapShield
//
//  Created by Ben Boyd on 1/28/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSCustomMapAnnotationUserLocation.h"

@implementation TSCustomMapAnnotationUserLocation

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
