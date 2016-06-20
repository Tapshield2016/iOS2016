//
//  CLLocation+Equal.m
//  TapShield
//
//  Created by Adam Share on 7/13/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "CLLocation+Params.h"
#import "NSDate+Utilities.h"

@implementation CLLocation (Params)

- (NSDictionary *)toLocationParameterDictionary {
    
    return @{@"latitude": @(self.coordinate.latitude),
             @"longitude": @(self.coordinate.longitude),
             @"accuracy": @(self.horizontalAccuracy),
             @"altitude": @(self.altitude),
             @"floor_level": @(self.floor.level),
             @"location_timestamp": self.timestamp.iso8601String};
}

@end
