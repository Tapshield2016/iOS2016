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
    self.travelMode = [attributes nonNullObjectForKey:@"travel_mode"];
    
    self.startLocation = [[TSJavelinAPINamedLocation alloc] initWithAttributes:[attributes nonNullObjectForKey:@"start_location"]];
    self.endLocation = [[TSJavelinAPINamedLocation alloc] initWithAttributes:[attributes nonNullObjectForKey:@"end_location"]];
    
    self.eta = [self reformattedTimeStamp:[attributes nonNullObjectForKey:@"eta"]];
    self.startTime = [self reformattedTimeStamp:[attributes nonNullObjectForKey:@"start_time"]];
    self.arrivalTime = [self reformattedTimeStamp:[attributes nonNullObjectForKey:@"arrival_time"]];
    
    self.entourageNotified = [[attributes nonNullObjectForKey:@"entourage_notified"] boolValue];
    
    self.locations = [self parseLocations:[attributes nonNullObjectForKey:@"locations"]];
    
    return self;
}

- (void)setTravelMode:(NSString *)travelMode {
    
    _travelMode = travelMode;
    
    if ([travelMode isEqualToString:@"D"]) {
        _transportType = MKDirectionsTransportTypeAutomobile;
    }
    else if ([travelMode isEqualToString:@"W"]) {
        _transportType = MKDirectionsTransportTypeWalking;
    }
    else {
        _transportType = MKDirectionsTransportTypeAny;
    }
}


- (void)setTransportType:(MKDirectionsTransportType)transportType {
    
    _transportType = transportType;
    
    if (_transportType == MKDirectionsTransportTypeAutomobile) {
        _travelMode = @"D";
    }
    else if (_transportType == MKDirectionsTransportTypeWalking) {
        _travelMode = @"W";
    }
    else {
        _travelMode = @"U";
    }
}


- (TSEntourageSessionPolyline *)parseLocations:(NSArray *)points {
    
    TSEntourageSessionPolyline *route;
    
    if (!points. count) {
        return route;
    }
    
    CLLocationCoordinate2D lineCoordinates[points.count];
    
    int i = 0;
    for (NSDictionary *attributes in points) {
        lineCoordinates[i] = CLLocationCoordinate2DMake([[attributes objectForKey:@"latitude"] doubleValue], [[attributes objectForKey:@"longitude"] doubleValue]);
        i++;
    }
    
    route = [TSEntourageSessionPolyline polylineWithCoordinates:lineCoordinates count:points.count];
    
    return route;
}


- (NSDictionary *)parametersFromSession {
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:10];
    
    if (self.travelMode) {
        [dictionary setObject:_travelMode forKey:@"travel_mode"];
    }
    
    if (self.startLocation) {
        [dictionary setObject:[_startLocation parametersFromLocation] forKey:@"start_location"];
    }
    
    if (self.endLocation) {
        [dictionary setObject:[_endLocation parametersFromLocation] forKey:@"end_location"];
    }
    
    if (self.eta) {
        [dictionary setObject:_eta.iso8601String forKey:@"eta"];
    }
    
    if (self.startTime) {
        [dictionary setObject:_startTime.iso8601String forKey:@"start_time"];
    }
    
    if (self.arrivalTime) {
        [dictionary setObject:_arrivalTime.iso8601String forKey:@"arrival_time"];
    }
    
    return dictionary;
}

@end
