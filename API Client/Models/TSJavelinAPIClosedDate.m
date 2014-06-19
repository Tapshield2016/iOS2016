//
//  TSJavelinAPIClosedDate.m
//  TapShield
//
//  Created by Adam Share on 6/16/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIClosedDate.h"

static NSString *const kModelStartDate = @"start_date";
static NSString *const kModelEndDate = @"end_date";

@implementation TSJavelinAPIClosedDate

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    _startDate = [self reformattedTimeStamp:[attributes nonNullObjectForKey:kModelStartDate]];
    _endDate = [self reformattedTimeStamp:[attributes nonNullObjectForKey:kModelEndDate] ];
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _startDate = [coder decodeObjectForKey:kModelStartDate];
        _endDate = [coder decodeObjectForKey:kModelEndDate];
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeObject:_startDate forKey:kModelStartDate];
    [encoder encodeObject:_endDate forKey:kModelEndDate];
}



@end
