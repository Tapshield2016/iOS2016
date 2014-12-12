//
//  TSSelectedDestinationAnnotation.h
//  TapShield
//
//  Created by Ben Boyd on 2/18/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseMapAnnotation.h"

@interface TSSelectedDestinationAnnotation : TSBaseMapAnnotation

- (id)initWithCoordinates:(CLLocationCoordinate2D)location placeName:(NSString *)placeName description:(NSString *)description travelType:(MKDirectionsTransportType)type;

@property (assign, nonatomic) MKDirectionsTransportType transportType;
@property (assign, nonatomic) BOOL temp;

@end
