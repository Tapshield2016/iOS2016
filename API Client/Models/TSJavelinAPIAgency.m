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

NSString * const TSJavelinAPIAgencyDidFinishSmallLogoDownload = @"TSJavelinAPIAgencyDidFinishSmallLogoDownload";

@interface TSJavelinAPIAgency ()

//UI Customization
@property (strong, nonatomic) NSString *agencyLogoUrl;
@property (strong, nonatomic) NSString *agencyAlternateLogoUrl;
@property (strong, nonatomic) NSString *agencySmallLogoUrl;

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
    _dispatcherScheduleStart = [attributes valueForKey:@"dispatcher_schedule_start"];
    _dispatcherScheduleEnd = [attributes valueForKey:@"dispatcher_schedule_end"];
    _agencyCenter.latitude = [[attributes objectForKey:@"agency_center_latitude"] doubleValue];
    _agencyCenter.longitude = [[attributes objectForKey:@"agency_center_longitude"] doubleValue];
    _alertCompletedMessage = [attributes objectForKey:@"alert_completed_message"];
    _requireDomainEmails = [[attributes objectForKey:@"require_domain_emails"] boolValue];
    _displayCommandAlert = [[attributes objectForKey:@"display_command_alert"] boolValue];
    _showAgencyNameInAppNavbar = [[attributes objectForKey:@"show_agency_name_in_app_navbar"] boolValue];
    _launchCallToDispatcherOnAlert = [[attributes objectForKey:@"launch_call_to_dispatcher_on_alert"] boolValue];
    
    self.agencyLogoUrl = [attributes objectForKey:@"agency_logo"];
    self.agencyAlternateLogoUrl = [attributes objectForKey:@"agency_alternate_logo"];
    self.agencySmallLogoUrl = [attributes objectForKey:@"agency_small_logo"];
    _agencyTheme = [attributes objectForKey:@"agency_theme"];
    
    [self setAgencyBoundaries:[attributes objectForKey:@"agency_boundaries"]];
    
    [self parseAgencyTheme:[attributes objectForKey:@"agency_theme"]];
    
//    "launch_call_to_dispatcher_on_alert": false,
//    "agency_logo": null,
//    "agency_alternate_logo": null,
//    "agency_small_logo": null,
//    "agency_theme": "{}"
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.url forKey:@"url"];
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
    
    if (_primaryColor) {
        [encoder encodeObject:_primaryColor forKey:@"primary_color"];
    }
    
    if (_secondaryColor) {
        [encoder encodeObject:_secondaryColor forKey:@"secondary_color"];
    }
    
    if (_smallLogo) {
        [encoder encodeObject:UIImagePNGRepresentation(_smallLogo) forKey:@"small_logo"];
    }
    
    if (_largeLogo) {
        [encoder encodeObject:UIImagePNGRepresentation(_largeLogo) forKey:@"large_logo"];
    }
    
    if (_alternateLogo) {
        [encoder encodeObject:UIImagePNGRepresentation(_alternateLogo) forKey:@"alternate_logo"];
    }
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.url = [decoder decodeObjectForKey:@"url"];
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
        
        if ([decoder containsValueForKey:@"primary_color"]) {
            _primaryColor = [decoder decodeObjectForKey:@"primary_color"];
        }
        
        if ([decoder containsValueForKey:@"secondary_color"]) {
            _secondaryColor = [decoder decodeObjectForKey:@"secondary_color"];
        }
        
        if ([decoder containsValueForKey:@"small_logo"]) {
            _smallLogo = [UIImage imageWithData:[decoder decodeObjectForKey:@"small_logo"]];
        }
        
        if ([decoder containsValueForKey:@"large_logo"]) {
            _largeLogo = [UIImage imageWithData:[decoder decodeObjectForKey:@"large_logo"]];
        }
        
        if ([decoder containsValueForKey:@"alternate_logo"]) {
            _alternateLogo = [UIImage imageWithData:[decoder decodeObjectForKey:@"alternate_logo"]];
        }
    }
    return self;
}


- (void)parseAgencyTheme:(NSString *)jsonString {
    
    if (!jsonString) {
        return;
    }
    
    NSData *webData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    if (!webData) {
        return;
    }
    NSError *error;
    NSDictionary *agencyTheme = [NSJSONSerialization JSONObjectWithData:webData options:0 error:&error];
    
    if ([agencyTheme isKindOfClass:[NSDictionary class]] && agencyTheme) {
        NSString *string = [agencyTheme objectForKey:@"primary_color"];
        if (string) {
            _primaryColor = UIColorFromRGB([self stringHexToInt:string]);
        }
        string = [agencyTheme objectForKey:@"secondary_color"];
        if (string) {
            _secondaryColor = UIColorFromRGB([self stringHexToInt:string]);
        }
    }
}

- (void)setAgencyLogoUrl:(NSString *)agencyLogoUrl {
    
    if ([agencyLogoUrl isKindOfClass:[NSNull class]]) {
        return;
    }
    
    _agencyLogoUrl = agencyLogoUrl;
    
    NSURL *url = [NSURL URLWithString:agencyLogoUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    
    [imageView setImageWithURLRequest:request
                          placeholderImage:nil
                                   success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                       self.largeLogo = image;
                                   } failure:nil];
}

- (void)setAgencySmallLogoUrl:(NSString *)agencySmallLogoUrl {
    
    if ([agencySmallLogoUrl isKindOfClass:[NSNull class]]) {
        return;
    }
    
    _agencySmallLogoUrl = agencySmallLogoUrl;
    
    NSURL *url = [NSURL URLWithString:agencySmallLogoUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    
    [imageView setImageWithURLRequest:request
                     placeholderImage:nil
                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                  self.smallLogo = image;
                                  
                                  [[NSNotificationCenter defaultCenter] postNotificationName:TSJavelinAPIAgencyDidFinishSmallLogoDownload
                                                                                      object:nil];
                              } failure:nil];
}

- (void)setAgencyAlternateLogoUrl:(NSString *)agencyAlternateLogoUrl {
    
    if ([agencyAlternateLogoUrl isKindOfClass:[NSNull class]]) {
        return;
    }
    
    _agencyAlternateLogoUrl = agencyAlternateLogoUrl;
    
    NSURL *url = [NSURL URLWithString:agencyAlternateLogoUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    
    [imageView setImageWithURLRequest:request
                     placeholderImage:nil
                              success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                  self.alternateLogo = image;
                              } failure:nil];
}

- (void)setAgencyBoundaries:(NSString *)agencyBoundariesString {
    
    if ([agencyBoundariesString isKindOfClass:[NSNull class]]) {
        return;
    }

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

- (int)stringHexToInt:(NSString *)string {
    NSScanner *scanner = [NSScanner scannerWithString:string];
    unsigned int temp;
    [scanner scanHexInt:&temp];
    
    return temp;
}

@end
