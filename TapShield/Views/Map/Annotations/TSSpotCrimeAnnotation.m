//
//  TSSpotCrimeAnnotation.m
//  TapShield
//
//  Created by Adam Share on 5/7/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSSpotCrimeAnnotation.h"

@implementation TSSpotCrimeAnnotation

- (instancetype)initWithSpotCrime:(TSSpotCrimeLocation *)location
{
    self = [super initWithCoordinates:location.coordinate placeName:[NSString stringWithFormat:@"%@ %@", location.type, location.date] description:location.address];
    if (self) {
        
        _type = location.type;
    }
    return self;
}

@end
