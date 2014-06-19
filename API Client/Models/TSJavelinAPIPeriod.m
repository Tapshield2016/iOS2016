//
//  TSJavelinAPIDispatcherTimes.m
//  TapShield
//
//  Created by Adam Share on 6/16/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIPeriod.h"

static NSString *const kModelDay = @"day";
static NSString *const kModelStartTime = @"open";
static NSString *const kModelEndTime = @"close";

@implementation TSJavelinAPIPeriod

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
 
    _day = [[attributes nonNullObjectForKey:kModelDay] integerValue];
    _startTime = [self timeFromString:[attributes nonNullObjectForKey:kModelStartTime]];
    _endTime = [self timeFromString:[attributes nonNullObjectForKey:kModelEndTime]];
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _day = [[coder decodeObjectForKey:kModelDay] integerValue];
        _startTime = [coder decodeObjectForKey:kModelStartTime];
        _endTime = [coder decodeObjectForKey:kModelEndTime];
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeObject:@(_day) forKey:kModelDay];
    [encoder encodeObject:_startTime forKey:kModelStartTime];
    [encoder encodeObject:_endTime forKey:kModelEndTime];
}


@end
