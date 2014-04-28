//
//  TSSelectedDestinationAnnotation.m
//  TapShield
//
//  Created by Ben Boyd on 2/18/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSSelectedDestinationAnnotation.h"

@implementation TSSelectedDestinationAnnotation

- (id)initWithCoordinates:(CLLocationCoordinate2D)location placeName:(NSString *)placeName description:(NSString *)description travelType:(MKDirectionsTransportType)type {
    
    self = [super initWithCoordinates:location placeName:placeName description:description];
    
    if (self) {
        self.transportType = type;
    }
    
    return self;
}

@end
