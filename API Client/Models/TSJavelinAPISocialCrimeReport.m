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
        _body = [attributes nonNullObjectForKey:@"body"];
        id distance = [attributes nonNullObjectForKey:@"distance"];
        if (distance) {
            _distance = [distance unsignedIntegerValue];
        }
        
        _reportImageUrl = [attributes nonNullObjectForKey:@"report_image_url"];
        _reportVideoUrl = [attributes nonNullObjectForKey:@"report_video_url"];
        _reportAudioUrl = [attributes nonNullObjectForKey:@"report_audio_url"];
        
        double lat = [[attributes nonNullObjectForKey:@"report_latitude"] doubleValue];
        double lon = [[attributes nonNullObjectForKey:@"report_longitude"] doubleValue];
        
        _location = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
        
        NSArray *shortArray = [NSArray arrayWithObjects:kSocialCrimeReportShortArray];
        
        _reportType = (int)[shortArray indexOfObject:[attributes nonNullObjectForKey:@"report_type"]];
        _user = [attributes nonNullObjectForKey:@"reporter"];
        _reportAnonymous = [[attributes nonNullObjectForKey:@"report_anonymous"] boolValue];
        _isSpam = [[attributes nonNullObjectForKey:@"flagged_spam"] boolValue];
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [super encodeWithCoder:encoder];
    
    [encoder encodeObject:_body forKey:@"body"];
    [encoder encodeInteger:_distance forKey:@"distance"];
    
    [encoder encodeObject:_reportImageUrl forKey:@"report_image_url"];
    [encoder encodeObject:_reportVideoUrl forKey:@"report_video_url"];
    [encoder encodeObject:_reportAudioUrl forKey:@"report_audio_url"];
    
    [encoder encodeObject:_location forKey:@"location"];
    
    [encoder encodeInt:_reportType forKey:@"report_type"];
    [encoder encodeObject:_user forKey:@"reporter"];
    [encoder encodeBool:_reportAnonymous forKey:@"report_anonymous"];
    [encoder encodeBool:_isSpam forKey:@"flagged_spam"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super initWithCoder:decoder])) {
        //decode properties, other class vars
        
        _body = [decoder decodeObjectForKey:@"body"];
        _distance = [decoder decodeIntegerForKey:@"distance"];
        
        _reportImageUrl = [decoder decodeObjectForKey:@"report_image_url"];
        _reportVideoUrl = [decoder decodeObjectForKey:@"report_video_url"];
        _reportAudioUrl = [decoder decodeObjectForKey:@"report_audio_url"];
        
        _location = [decoder decodeObjectForKey:@"location"];
        
        _reportType = [decoder decodeIntForKey:@"report_type"];
        _user = [decoder decodeObjectForKey:@"reporter"];
        _reportAnonymous = [decoder decodeBoolForKey:@"report_anonymous"];
        _isSpam = [decoder decodeBoolForKey:@"flagged_spam"];
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
