//
//  TSJavelinAPIAgency.m
//  Javelin
//
//  Created by Ben Boyd on 10/25/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIAgency.h"

@implementation TSJavelinAPIAgency

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super initWithAttributes:attributes];
    if (!self) {
        return nil;
    }
    
    _name = [attributes valueForKey:@"name"];
    _domain = [attributes valueForKey:@"domain"];
    _dispatcherPhoneNumber = [attributes valueForKey:@"dispatcher_phone_number"];
    _dispatcherSecondaryPhoneNumber = [attributes valueForKey:@"dispatcher_secondary_phone_number"];
    _dispatcherScheduleStart = [attributes valueForKey:@"dispatcher_schedule_start"];
    _dispatcherScheduleEnd = [attributes valueForKey:@"dispatcher_schedule_end"];
    _agencyCenter.latitude = [[attributes objectForKey:@"agency_center_latitude"] doubleValue];
    _agencyCenter.longitude = [[attributes objectForKey:@"agency_center_longitude"] doubleValue];
    _alertCompletedMessage = [attributes objectForKey:@"alert_completed_message"];
    _requireDomainEmails = [[attributes objectForKey:@"require_domain_emails"] boolValue];
    _displayCommandAlert = [[attributes objectForKey:@"display_command_alert"] boolValue];
    _showAgencyNameInAppNavbar = [[attributes objectForKey:@"show_agency_name_in_app_navbar"] boolValue];
    [self setAgencyBoundaries:[attributes objectForKey:@"agency_boundaries"]];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.url forKey:@"url"];
    [encoder encodeObject:[NSNumber numberWithUnsignedInteger:self.identifier] forKey:@"identifier"];
    [encoder encodeObject:_name forKey:@"name"];
    [encoder encodeObject:_domain forKey:@"domain"];
    [encoder encodeObject:_dispatcherPhoneNumber forKey:@"dispatcherPhoneNumber"];
    [encoder encodeObject:_alertCompletedMessage forKey:@"alert_completed_message"];
    [encoder encodeObject:[NSNumber numberWithBool:_requireDomainEmails] forKey:@"require_domain_emails"];
    [encoder encodeObject:[NSNumber numberWithBool:_displayCommandAlert] forKey:@"display_command_alert"];
    [encoder encodeObject:[NSNumber numberWithBool:_showAgencyNameInAppNavbar] forKey:@"show_agency_name_in_app_navbar"];

    if (_dispatcherSecondaryPhoneNumber) {
        [encoder encodeObject:_dispatcherSecondaryPhoneNumber forKey:@"dispatcherSecondaryPhoneNumber"];
    }
    
    if (_dispatcherScheduleStart) {
        [encoder encodeObject:_dispatcherScheduleStart forKey:@"dispatcherScheduleStart"];
    }

    if (_dispatcherScheduleEnd) {
        [encoder encodeObject:_dispatcherScheduleEnd forKey:@"dispatcherScheduleEnd"];
    }
    
    if (CLLocationCoordinate2DIsValid(_agencyCenter)) {
        [encoder encodeObject:[NSNumber numberWithDouble:_agencyCenter.latitude] forKey:@"agencyCenter.latitude"];
        [encoder encodeObject:[NSNumber numberWithDouble:_agencyCenter.longitude] forKey:@"agencyCenter.longitude"];
    }
    
    if (_agencyBoundaries) {
        [encoder encodeObject:_agencyBoundaries forKey:@"agency_boundaries"];
    }
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.url = [decoder decodeObjectForKey:@"url"];
        self.identifier = [[decoder decodeObjectForKey:@"identifier"] unsignedIntegerValue];
        _name = [decoder decodeObjectForKey:@"name"];
        _domain = [decoder decodeObjectForKey:@"domain"];
        _dispatcherPhoneNumber = [decoder decodeObjectForKey:@"dispatcherPhoneNumber"];
        _alertCompletedMessage = [decoder decodeObjectForKey:@"alert_completed_message"];
        _requireDomainEmails = [[decoder decodeObjectForKey:@"require_domain_emails"] boolValue];
        _displayCommandAlert = [[decoder decodeObjectForKey:@"display_command_alert"] boolValue];
        _showAgencyNameInAppNavbar = [[decoder decodeObjectForKey:@"show_agency_name_in_app_navbar"] boolValue];
        
        if ([decoder containsValueForKey:@"dispatcherSecondaryPhoneNumber"]) {
            _dispatcherSecondaryPhoneNumber = [decoder decodeObjectForKey:@"dispatcherSecondaryPhoneNumber"];
        }
        
        if ([decoder containsValueForKey:@"dispatcherScheduleStart"]) {
            _dispatcherScheduleStart = [decoder decodeObjectForKey:@"dispatcherScheduleStart"];
        }
        
        if ([decoder containsValueForKey:@"dispatcherScheduleEnd"]) {
            _dispatcherScheduleStart = [decoder decodeObjectForKey:@"dispatcherScheduleEnd"];
        }
        
        if ([decoder containsValueForKey:@"agencyCenter.latitude"]) {
            _agencyCenter.latitude = [[decoder decodeObjectForKey:@"agencyCenter.latitude"] doubleValue];
            _agencyCenter.longitude = [[decoder decodeObjectForKey:@"agencyCenter.longitude"] doubleValue];
        }
        
        if ([decoder containsValueForKey:@"agency_boundaries"]) {
            _agencyBoundaries = [decoder decodeObjectForKey:@"agency_boundaries"];
        }
    }
    return self;
}

- (void)setAgencyBoundaries:(NSString *)agencyBoundariesString {

    if ([agencyBoundariesString rangeOfString:@","].location == NSNotFound) {
        return;
    }
    
    NSString *noWhiteSpace = [agencyBoundariesString stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *string = [noWhiteSpace stringByReplacingOccurrencesOfString:@"[\"" withString:@""];
    NSArray *splitAgencyBoundaryString = [string componentsSeparatedByString:@"\",\""];

    NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
    for (int i=0; i<splitAgencyBoundaryString.count; i++) {
        NSArray *coordinatesArray = [[splitAgencyBoundaryString objectAtIndex:i] componentsSeparatedByString:@","];
        if (coordinatesArray.count > 1) {
            double lat = [[coordinatesArray objectAtIndex:0] doubleValue];
            double lon = [[coordinatesArray objectAtIndex:1] doubleValue];
            CLLocation *location =  [[CLLocation alloc] initWithLatitude:lat longitude:lon];
            [mutableArray addObject:location];
        }
    }
    _agencyBoundaries = mutableArray;
}

@end