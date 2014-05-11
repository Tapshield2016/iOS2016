//
//  TSSpotCrimeLocation.m
//  TapShield
//
//  Created by Adam Share on 3/30/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSSpotCrimeLocation.h"

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
        self.date = [attributes objectForKey:@"date"];
    }
    
    return self;
}

+ (UIImage *)imageFromSpotCrimeType:(NSString *)type {
    
    
    type = [type stringByReplacingOccurrencesOfString:@" " withString:@""];
    type = [type stringByReplacingOccurrencesOfString:@"/" withString:@""];
    NSString *imageName = [NSString stringWithFormat:@"%@%@%@", IconImagePrefix, [type lowercaseString], IconImageSuffix];
    UIImage *image = [UIImage imageNamed:imageName];
    
    return image;
}

@end
