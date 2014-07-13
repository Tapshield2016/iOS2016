//
//  TSSpotCrimeLocation.m
//  TapShield
//
//  Created by Adam Share on 3/30/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSSpotCrimeLocation.h"
#import "TSSpotCrimeAPIClient.h"

static NSString * const PinImagePrefix = @"pins_";
static NSString * const RedImageSuffix = @"_red";
static NSString * const BlueImageSuffix = @"_blue";

@implementation TSSpotCrimeLocation

- (id)initWithAttributes:(NSDictionary *)attributes {
    
    self = [super initWithLatitude:[[attributes objectForKey:@"lat"] floatValue] longitude:[[attributes objectForKey:@"lon"] floatValue]];
    if (self) {
        self.type = [attributes objectForKey:@"type"];
        self.address = [attributes objectForKey:@"address"];
        self.link = [attributes objectForKey:@"link"];
        self.cdid = [[attributes objectForKey:@"cdid"] unsignedIntegerValue];
        
        NSString *dateString = [attributes objectForKey:@"date"];
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"MM/dd/yy h:mm a"];
        NSDate *myDate = [dateFormat dateFromString: dateString];
        self.date = myDate;
    }
    
    return self;
}

+ (UIImage *)mapImageFromSpotCrimeType:(NSString *)type {
    
    
    type = [type stringByReplacingOccurrencesOfString:@" " withString:@""];
    type = [type stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSString *imageName = [NSString stringWithFormat:@"%@%@%@", PinImagePrefix, [type lowercaseString], RedImageSuffix];
    UIImage *image = [UIImage imageNamed:imageName];
    
    return image;
}

+ (UIImage *)mapImageFromSocialCrimeType:(NSString *)type {
    
    type = [type stringByReplacingOccurrencesOfString:@" " withString:@""];
    type = [type stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSString *imageName = [NSString stringWithFormat:@"%@%@%@", PinImagePrefix, [type lowercaseString], BlueImageSuffix];
    UIImage *image = [UIImage imageNamed:imageName];
    
    return image;
}

+ (UIImage *)imageForSpotCrimeType:(NSString *)type {
    
    type = [type stringByReplacingOccurrencesOfString:@" " withString:@""];
    type = [type stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSString *imageName = [NSString stringWithFormat:@"bubble_%@_icon", [type lowercaseString]];
    UIImage *image = [UIImage imageNamed:imageName];
    if (!image) {
        image = [UIImage imageNamed:@"bubble_other_icon"];
    }
    
    return image;
}


- (void)setTypeFromDescription {
    
    NSString *type = [[NSArray arrayWithObjects:kSpotCrimeTypesArray] objectAtIndex:trespasser];
    
    if ([_eventDescription rangeOfString:type
                                 options:NSCaseInsensitiveSearch].location != NSNotFound) {
        _type = type;
        return;
    }
    
    type = [[NSArray arrayWithObjects:kSpotCrimeTypesArray] objectAtIndex:missingPerson];
    if ([_eventDescription rangeOfString:type
                                 options:NSCaseInsensitiveSearch].location != NSNotFound) {
        _type = type;
        return;
    }
    
    type = [[NSArray arrayWithObjects:kSpotCrimeTypesArray] objectAtIndex:suspiciousActivity];
    if ([_eventDescription rangeOfString:@"suspicious"
                                 options:NSCaseInsensitiveSearch].location != NSNotFound) {
        _type = type;
        return;
    }
    
    type = [[NSArray arrayWithObjects:kSpotCrimeTypesArray] objectAtIndex:disturbance];
    if ([_eventDescription rangeOfString:type
                                 options:NSCaseInsensitiveSearch].location != NSNotFound) {
        _type = type;
        return;
    }
    
    type = [[NSArray arrayWithObjects:kSpotCrimeTypesArray] objectAtIndex:vehicle];
    NSArray *array = @[@"hit and run",
                       @"hit & run",
                       @"car accident",
                       @"vehicle pursuit",
                       @"veh pursuit"];
    for (NSString *string in array) {
        if ([_eventDescription rangeOfString:string
                                     options:NSCaseInsensitiveSearch].location != NSNotFound) {
            _type = type;
            return;
        }
    }
}


@end
