//
//  TSJavelinAPIEntourageSession.m
//  TapShield
//
//  Created by Adam Share on 11/9/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIEntourageSession.h"

@implementation TSJavelinAPIEntourageSession

- (id)initWithAttributes:(NSDictionary *)attributes {
    
    self = [super initWithAttributes:attributes];
    if (!self) {
        return self;
    }
    
    self.status = [attributes nonNullObjectForKey:@"status"];
    
    self.startLocation = [self parseLocation:[attributes nonNullObjectForKey:@"start_location"]];
    self.endLocation = [self parseLocation:[attributes nonNullObjectForKey:@"end_location"]];
    
    self.eta = [self reformattedTimeStamp:[attributes nonNullObjectForKey:@"eta"]];
    self.startTime = [self reformattedTimeStamp:[attributes nonNullObjectForKey:@"start_time"]];
    self.arrivalTime = [self reformattedTimeStamp:[attributes nonNullObjectForKey:@"arrival_time"]];
    
    self.entourageNotified = [[attributes nonNullObjectForKey:@"entourage_notified"] boolValue];
    
    self.locations = [self parseLocations:[attributes nonNullObjectForKey:@"arrival_time"]];
    
    return self;
}


- (MKPolyline *)parseLocations:(NSArray *)points {
    MKPolyline *route;
    
    return route;
}


- (MKMapItem *)parseLocation:(NSArray *)location {
    MKMapItem *item;
    
    
    return item;
}


@end
