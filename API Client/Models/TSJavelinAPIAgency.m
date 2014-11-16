//
//  TSJavelinAPIAgency.m
//  Javelin
//
//  Created by Ben Boyd on 10/25/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIAgency.h"
#import "TSJavelinAPIClient.h"
#import "UIImageView+AFNetworking.h"
#import "UIImage+Resize.h"
#import "TSJavelinAPIRegion.h"
#import "TSJavelinAPIDispatchCenter.h"
#import "TSJavelinAPIClosedDate.h"
#import "TSJavelinAPIPeriod.h"

NSString * const TSJavelinAPIAgencyDidFinishSmallLogoDownload = @"TSJavelinAPIAgencyDidFinishSmallLogoDownload";

@interface TSJavelinAPIAgency ()

@end

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
    _alertModeName = [attributes valueForKey:@"alert_mode_name"];
    
    _dispatcherScheduleStart = [attributes valueForKey:@"dispatcher_schedule_start"];
    _dispatcherScheduleEnd = [attributes valueForKey:@"dispatcher_schedule_end"];
    
    _agencyCenter.latitude = [[attributes nonNullObjectForKey:@"agency_center_latitude"] doubleValue];
    _agencyCenter.longitude = [[attributes nonNullObjectForKey:@"agency_center_longitude"] doubleValue];
    
    _requireDomainEmails = [[attributes nonNullObjectForKey:@"require_domain_emails"] boolValue];
    
    _alertCompletedMessage = [attributes nonNullObjectForKey:@"alert_completed_message"];
    _displayCommandAlert = [[attributes nonNullObjectForKey:@"display_command_alert"] boolValue];
    _showAgencyNameInAppNavbar = [[attributes nonNullObjectForKey:@"show_agency_name_in_app_navbar"] boolValue];
    
    _launchCallToDispatcherOnAlert = [[attributes nonNullObjectForKey:@"launch_call_to_dispatcher_on_alert"] boolValue];
    
    if (![[attributes nonNullObjectForKey:@"agency_info_url"] isKindOfClass:[NSNull class]]) {
        _infoUrl = [attributes nonNullObjectForKey:@"agency_info_url"];
    }
    if (![[attributes nonNullObjectForKey:@"agency_rss_url"] isKindOfClass:[NSNull class]]) {
        _rssFeed = [attributes nonNullObjectForKey:@"agency_rss_url"];
    }
    
    [self setAgencyBoundaries:[attributes nonNullObjectForKey:@"agency_boundaries"]];
    
    [self setRegions:[attributes nonNullObjectForKey:@"region"]];
    [self setDispatchCenters:[attributes nonNullObjectForKey:@"dispatch_center"]];
    
    if ([attributes nonNullObjectForKey:@"theme"]) {
        self.theme = [[TSJavelinAPITheme alloc] initWithAttributes:[attributes nonNullObjectForKey:@"theme"]];
    }
    
    return self;
}

- (instancetype)updateWithAttributes:(NSDictionary *)attributes  {
    
    _name = [attributes valueForKey:@"name"];
    _domain = [attributes valueForKey:@"domain"];
    _dispatcherPhoneNumber = [attributes valueForKey:@"dispatcher_phone_number"];
    _dispatcherSecondaryPhoneNumber = [attributes valueForKey:@"dispatcher_secondary_phone_number"];
    _alertModeName = [attributes valueForKey:@"alert_mode_name"];
    
    _dispatcherScheduleStart = [attributes valueForKey:@"dispatcher_schedule_start"];
    _dispatcherScheduleEnd = [attributes valueForKey:@"dispatcher_schedule_end"];
    
    _agencyCenter.latitude = [[attributes nonNullObjectForKey:@"agency_center_latitude"] doubleValue];
    _agencyCenter.longitude = [[attributes nonNullObjectForKey:@"agency_center_longitude"] doubleValue];
    
    _requireDomainEmails = [[attributes nonNullObjectForKey:@"require_domain_emails"] boolValue];
    
    _alertCompletedMessage = [attributes nonNullObjectForKey:@"alert_completed_message"];
    _displayCommandAlert = [[attributes nonNullObjectForKey:@"display_command_alert"] boolValue];
    _showAgencyNameInAppNavbar = [[attributes nonNullObjectForKey:@"show_agency_name_in_app_navbar"] boolValue];
    
    _launchCallToDispatcherOnAlert = [[attributes nonNullObjectForKey:@"launch_call_to_dispatcher_on_alert"] boolValue];
    
    if (![[attributes nonNullObjectForKey:@"agency_info_url"] isKindOfClass:[NSNull class]]) {
        _infoUrl = [attributes nonNullObjectForKey:@"agency_info_url"];
    }
    if (![[attributes nonNullObjectForKey:@"agency_rss_url"] isKindOfClass:[NSNull class]]) {
        _rssFeed = [attributes nonNullObjectForKey:@"agency_rss_url"];
    }
    
    [self setAgencyBoundaries:[attributes nonNullObjectForKey:@"agency_boundaries"]];
    
    [self setRegions:[attributes nonNullObjectForKey:@"region"]];
    [self setDispatchCenters:[attributes nonNullObjectForKey:@"dispatch_center"]];
    
    if ([attributes nonNullObjectForKey:@"theme"]) {
        if (self.theme) {
            self.theme = [self.theme updateWithAttributes:[attributes nonNullObjectForKey:@"theme"]];
        }
        else {
            self.theme = [[TSJavelinAPITheme alloc] initWithAttributes:[attributes nonNullObjectForKey:@"theme"]];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.url forKey:@"url"];
    [encoder encodeObject:_name forKey:@"name"];
    [encoder encodeObject:_domain forKey:@"domain"];
    [encoder encodeObject:_dispatcherPhoneNumber forKey:@"dispatcherPhoneNumber"];
    
    [encoder encodeObject:_alertModeName forKey:@"alert_mode_name"];
    
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
    
    if (_infoUrl) {
        [encoder encodeObject:_infoUrl forKey:@"agency_info_url"];
    }
    
    if (_rssFeed) {
        [encoder encodeObject:_rssFeed forKey:@"agency_rss_url"];
    }
    
    if (_regions) {
        [encoder encodeObject:_regions forKey:@"region"];
    }
    
    if (_dispatchCenters) {
        [encoder encodeObject:_dispatchCenters forKey:@"dispatch_center"];
    }
    
    if (_theme) {
        [encoder encodeObject:_theme forKey:@"theme"];
    }
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.url = [decoder decodeObjectForKey:@"url"];
        _name = [decoder decodeObjectForKey:@"name"];
        _domain = [decoder decodeObjectForKey:@"domain"];
        _dispatcherPhoneNumber = [decoder decodeObjectForKey:@"dispatcherPhoneNumber"];
        _alertModeName = [decoder decodeObjectForKey:@"alert_mode_name"];
        
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
        
        if ([decoder containsValueForKey:@"agency_info_url"]) {
            _infoUrl = [decoder decodeObjectForKey:@"agency_info_url"];
        }
        
        if ([decoder containsValueForKey:@"agency_rss_url"]) {
            _rssFeed = [decoder decodeObjectForKey:@"agency_rss_url"];
        }
        
        if ([decoder containsValueForKey:@"region"]) {
            _regions = [decoder decodeObjectForKey:@"region"];
        }
        
        if ([decoder containsValueForKey:@"dispatch_center"]) {
            _dispatchCenters = [decoder decodeObjectForKey:@"dispatch_center"];
        }
        
        if ([decoder containsValueForKey:@"theme"]) {
            _theme = [decoder decodeObjectForKey:@"theme"];
        }
    }
    return self;
}


- (void)setRegions:(NSArray *)regions {
    
    if (!regions || !regions.count) {
        return;
    }
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:regions.count];
    for (NSDictionary *dictionary in regions) {
        TSJavelinAPIRegion *region = [[TSJavelinAPIRegion alloc] initWithAttributes:dictionary];
        [mutableArray addObject:region];
    }
    
    _regions = mutableArray;
}

- (void)setDispatchCenters:(NSArray *)dispatchCenters {
    
    if (!dispatchCenters || !dispatchCenters.count) {
        return;
    }
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:dispatchCenters.count];
    for (NSDictionary *dictionary in dispatchCenters) {
        TSJavelinAPIDispatchCenter *center = [[TSJavelinAPIDispatchCenter alloc] initWithAttributes:dictionary];
        [mutableArray addObject:center];
    }
    
    _dispatchCenters = mutableArray;
}


- (void)setAgencyBoundaries:(NSString *)agencyBoundariesString {
    
    if ([agencyBoundariesString isKindOfClass:[NSNull class]]) {
        return;
    }

    if ([agencyBoundariesString rangeOfString:@","].location == NSNotFound) {
        return;
    }
    
    NSString *noWhiteSpace = [agencyBoundariesString stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *noBreaks = [noWhiteSpace stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    noBreaks = [noBreaks stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    NSString *string = [noBreaks stringByReplacingOccurrencesOfString:@"[\"" withString:@""];
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

- (int)stringHexToInt:(NSString *)string {
    NSScanner *scanner = [NSScanner scannerWithString:string];
    unsigned int temp;
    [scanner scanHexInt:&temp];
    
    return temp;
}

- (NSArray *)openDispatchCenters {
    
    if (!_dispatchCenters) {
        return nil;
    }
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:_dispatchCenters.count];
    for (TSJavelinAPIDispatchCenter *center in _dispatchCenters) {
        if ([center isOpen]) {
            [mutableArray addObject:center];
        }
    }
    
    if (!mutableArray.count) {
        return nil;
    }
    
    return mutableArray;
}

- (NSDate *)nextOpeningHoursStatusChange {
    
   NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:5];
    
    for (TSJavelinAPIDispatchCenter *dispatchCenter in _dispatchCenters) {
        for (TSJavelinAPIClosedDate *closedDate in dispatchCenter.closedDates) {
            if (closedDate.startDate.isInFuture) {
                [mutableArray addObject:closedDate.startDate];
            }
            else if (closedDate.endDate.isInFuture) {
                [mutableArray addObject:closedDate.endDate];
            }
        }
        
        for (TSJavelinAPIPeriod *period in dispatchCenter.openingHours) {
            
            NSDate *startDate = [[NSDate nextWeekday:period.day] setTime:period.startTime];
            NSDate *endDate = [[NSDate nextWeekday:period.day] setTime:period.endTime];
            
            if (startDate.isInFuture) {
                [mutableArray addObject:startDate];
            }
            else if (endDate.isInFuture) {
                [mutableArray addObject:endDate];
            }
        }
    }
    
    [mutableArray sortUsingSelector:@selector(compare:)];
    
    if (mutableArray.count) {
        return [mutableArray firstObject];
    }
    
    return nil;
}

- (BOOL)domainMatchesEmail:(NSString *)email {
    
    NSString  *emailDomain = [[_domain lowercaseString] stringByReplacingOccurrencesOfString:@"@" withString:@""];
    NSArray *userEmailDomain = [[email lowercaseString] componentsSeparatedByString:@"@"];
    
    if ([[userEmailDomain lastObject] rangeOfString:emailDomain].location == NSNotFound) {
        return NO;
    }
    
    return YES;
}


@end
