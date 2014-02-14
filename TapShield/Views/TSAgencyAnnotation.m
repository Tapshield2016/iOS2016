//
//  TSAgencyAnnotation.m
//  TapShield
//
//  Created by Adam Share on 2/13/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSAgencyAnnotation.h"

@implementation TSAgencyAnnotation

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
