//
//  TSJavelinAPISocialCrimeReport.m
//  TapShield
//
//  Created by Adam Share on 5/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPISocialCrimeReport.h"

@implementation TSJavelinAPISocialCrimeReport

//body = Assault;
//"creation_date" = "2014-05-11T09:08:36.690Z";
//distance = "0.01534496941983814";
//"last_modified" = "2014-05-11T09:08:36.690Z";
//"report_image_url" = "<null>";
//"report_latitude" = "26.115649518878";
//"report_longitude" = "-80.1394969373621";
//"report_point" = "POINT (-80.1394969373620967 26.1156495188780085)";
//"report_type" = AS;
//reporter = "https://dev.tapshield.com/api/v1/users/112/";
//url = "https://dev.tapshield.com/api/v1/social-crime-reports/32/";

- (instancetype)initWithAttributes:(NSDictionary *)attributes
{
    self = [super initWithAttributes:attributes];
    if (self) {
        _body = [attributes objectForKey:@"body"];
        _creationDate = [self reformattedTimeStamp:[attributes objectForKey:@"creation_date"]];
        
        id distance = [attributes objectForKey:@"distance"];
        if (distance && ![distance isKindOfClass:[NSNull class]]) {
            _distance = [distance unsignedIntegerValue];
        }
        
        _lastModified = [self reformattedTimeStamp:[attributes valueForKey:@"last_modified"]];
        
        _reportImageUrl = [self filterNSNull:[attributes objectForKey:@"report_image_url"]];
        _reportVideoUrl = [self filterNSNull:[attributes objectForKey:@"report_video_url"]];
        _reportAudioUrl = [self filterNSNull:[attributes objectForKey:@"report_audio_url"]];
        
        double lat = [[attributes objectForKey:@"report_latitude"] doubleValue];
        double lon = [[attributes objectForKey:@"report_longitude"] doubleValue];
        
        _location = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
        
        NSArray *shortArray = [NSArray arrayWithObjects:kSocialCrimeReportShortArray];
        
        _reportType = [shortArray indexOfObject:[attributes objectForKey:@"report_type"]];
        _user = [attributes objectForKey:@"reporter"];
        _reportAnonymous = [[attributes objectForKey:@"report_anonymous"] boolValue];
    }
    return self;
}

+ (NSArray *)socialCrimeReportArray:(NSArray *)socialCrimes {
    
    NSMutableArray *mutableArray = [[NSMutableArray alloc] initWithCapacity:socialCrimes.count];
    for (NSDictionary *dictionary in socialCrimes) {
        TSJavelinAPISocialCrimeReport *crime = [[TSJavelinAPISocialCrimeReport alloc] initWithAttributes:dictionary];
        [mutableArray addObject:crime];
    }
    
    return mutableArray;
}


+ (NSString*)socialReportTypesToString:(SocialReportTypes)enumValue {
    NSArray *typesArray = [[NSArray alloc] initWithObjects:kSocialCrimeReportLongArray];
    return [typesArray objectAtIndex:enumValue];
}

+ (NSString*)socialReportTypesToShortString:(SocialReportTypes)enumValue {
    NSArray *typesArray = [[NSArray alloc] initWithObjects:kSocialCrimeReportShortArray];
    return [typesArray objectAtIndex:enumValue];
}



@end
