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
    
    self.startLocation = [self parseLocation:[attributes nonNullObjectForKey:@"start_location"]];
    self.endLocation = [self parseLocation:[attributes nonNullObjectForKey:@"end_location"]];
    
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


- (MKMapItem *)parseLocation:(NSDictionary *)attributes {
    MKMapItem *item;
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:[[attributes objectForKey:@"latitude"] doubleValue] longitude:[[attributes objectForKey:@"longitude"] doubleValue]];
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:location.coordinate addressDictionary:nil];
    
    item = [[MKMapItem alloc] initWithPlacemark:placemark];
    item.name = [attributes objectForKey:@"name"];
    
    return item;
}


@end
