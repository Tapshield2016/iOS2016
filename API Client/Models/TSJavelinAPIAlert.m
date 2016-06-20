//
//  TSJavelinAPIAlert.m
//  Javelin
//
//  Created by Ben Boyd on 10/25/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIAlert.h"
#import "TSJavelinAPIAgency.h"
#import "TSJavelinAPIClient.h"

@implementation TSJavelinAPIAlert

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super initWithAttributes:attributes];
    if (!self) {
        return nil;
    }
    
    _agency = [[TSJavelinAPIAgency alloc] initWithOnlyURLAttribute:attributes forKey:@"agency"];
    
    if (![[attributes nonNullObjectForKey:@"agency_user"] isKindOfClass:[NSString class]]) {
        _agencyUser = [[TSJavelinAPIUser alloc] initWithAttributes:[attributes nonNullObjectForKey:@"agency_user"]];
    }
    _agencyDispatcher = [[TSJavelinAPIUser alloc] initWithOnlyURLAttribute:attributes forKey:@"agency_dispatcher"];
    
    _completedTime = [self reformattedTimeStamp:[attributes nonNullObjectForKey:@"completed_time"]];
    _disarmedTime = [self reformattedTimeStamp:[attributes nonNullObjectForKey:@"disarmed_time"]];
    _status = [attributes nonNullObjectForKey:@"status"];
    _initiatedBy = [attributes nonNullObjectForKey:@"initiated_by"];
    
    _notes = [attributes nonNullObjectForKey:@"notes"];
    _callLength = [[attributes nonNullObjectForKey:@"call_length"] integerValue];
    _inBounds = [[attributes nonNullObjectForKey:@"in_bounds"] boolValue];

    [self setLocation:[attributes nonNullObjectForKey:@"latest_location"]];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [super encodeWithCoder:encoder];
    
    [encoder encodeObject:_agency forKey:@"agency"];
    [encoder encodeObject:_agencyUser forKey:@"agency_user"];
    [encoder encodeObject:_agencyDispatcher forKey:@"agency_dispatcher"];
    
    
    [encoder encodeObject:_completedTime forKey:@"completed_time"];
    [encoder encodeObject:_disarmedTime forKey:@"disarmed_time"];
    
    [encoder encodeObject:_status forKey:@"status"];
    [encoder encodeObject:_initiatedBy forKey:@"initiated_by"];
    
    [encoder encodeObject:_notes forKey:@"notes"];
    [encoder encodeInteger:_callLength forKey:@"call_length"];
    [encoder encodeBool:_inBounds forKey:@"in_bounds"];
    
    [encoder encodeObject:_latestLocation forKey:@"latest_location"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        
        _agency = [decoder decodeObjectForKey:@"agency"];
        _agencyUser = [decoder decodeObjectForKey:@"agency_user"];
        _agencyDispatcher = [decoder decodeObjectForKey:@"agency_dispatcher"];
        
        
        _completedTime = [decoder decodeObjectForKey:@"completed_time"];
        _disarmedTime = [decoder decodeObjectForKey:@"disarmed_time"];
        
        _status = [decoder decodeObjectForKey:@"status"];
        _initiatedBy = [decoder decodeObjectForKey:@"initiated_by"];
        
        _notes = [decoder decodeObjectForKey:@"notes"];
        _callLength = [decoder decodeIntegerForKey:@"call_length"];
        _inBounds = [decoder decodeBoolForKey:@"in_bounds"];
        
        _latestLocation = [decoder decodeObjectForKey:@"latest_location"];
    }
    return self;
}

- (void)setLocation:(NSDictionary *)attributes {
    
    if (attributes) {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([[attributes nonNullObjectForKey:@"latitude"] doubleValue], [[attributes nonNullObjectForKey:@"longitude"] doubleValue]);
        _latestLocation = [[CLLocation alloc] initWithCoordinate:coordinate
                                                        altitude:[[attributes nonNullObjectForKey:@"altitude"] doubleValue]
                                              horizontalAccuracy:[[attributes nonNullObjectForKey:@"accuracy"] integerValue]
                                                verticalAccuracy:0
                                                       timestamp:[self reformattedTimeStamp:[attributes nonNullObjectForKey:@"creation_date"]]];
    }
}

@end
