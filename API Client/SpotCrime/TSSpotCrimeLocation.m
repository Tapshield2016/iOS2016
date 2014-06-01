//
//  TSSpotCrimeLocation.m
//  TapShield
//
//  Created by Adam Share on 3/30/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSSpotCrimeLocation.h"

static NSString * const SpotCrimeIconImagePrefix = @"spotcrime_";

static NSString * const IconImagePrefix = @"pins_";
static NSString * const IconImageSuffix = @"_icon";

@implementation TSSpotCrimeLocation

- (id)initWithAttributes:(NSDictionary *)attributes {
    
    self = [super initWithLatitude:[[attributes objectForKey:@"lat"] floatValue] longitude:[[attributes objectForKey:@"lon"] floatValue]];
    if (self) {
        self.type = [attributes objectForKey:@"type"];
        self.address = [attributes objectForKey:@"address"];
        self.link = [attributes objectForKey:@"link"];
        self.cdid = [attributes objectForKey:@"cdid"];
        
        NSString *dateString = [attributes objectForKey:@"date"];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MM/dd/yy h:mm a"];
        NSDate *myDate = [dateFormat dateFromString: dateString];
        self.date = myDate;
    }
    
    return self;
}

- (instancetype)initWithSocialCrimeReport:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        self.type = [dictionary objectForKey:@"type"];
        self.address = [dictionary objectForKey:@"address"];
        self.link = [dictionary objectForKey:@"link"];
        self.cdid = [dictionary objectForKey:@"cdid"];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyy-MM-dd hh:mm:ss a"];
        NSDate *myDate = [df dateFromString:[dictionary objectForKey:@"date"]];
        self.date = myDate;
//        self.eventDescription = 
    }
    return self;
}

+ (UIImage *)imageFromSpotCrimeType:(NSString *)type {
    
    
    type = [type stringByReplacingOccurrencesOfString:@" " withString:@""];
    type = [type stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSString *imageName = [NSString stringWithFormat:@"%@%@", SpotCrimeIconImagePrefix, [type lowercaseString]];
    UIImage *image = [UIImage imageNamed:imageName];
    
    return image;
}

+ (UIImage *)imageFromSocialCrimeType:(NSString *)type {
    
    type = [type stringByReplacingOccurrencesOfString:@" " withString:@""];
    type = [type stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSString *imageName = [NSString stringWithFormat:@"%@%@%@", IconImagePrefix, [type lowercaseString], IconImageSuffix];
    UIImage *image = [UIImage imageNamed:imageName];
    
    return image;
}

@end
