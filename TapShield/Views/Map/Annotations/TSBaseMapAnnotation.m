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
        _firstAdd = YES;
    }
    return self;
}

- (BOOL)isEqual:(TSBaseMapAnnotation *)annotation;
{
    if (![annotation isKindOfClass:[TSBaseMapAnnotation class]]) {
        return NO;
    }
    
    return (self.coordinate.latitude == annotation.coordinate.latitude &&
            self.coordinate.longitude == annotation.coordinate.longitude &&
            [self.title isEqualToString:annotation.title] &&
            [self.subtitle isEqualToString:annotation.subtitle] &&
            [self.groupTag isEqualToString:annotation.groupTag]);
}

@end
