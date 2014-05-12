//
//  TSJavelinAPIMassAlert.m
//  Javelin
//
//  Created by Ben Boyd on 10/25/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIMassAlert.h"

@implementation TSJavelinAPIMassAlert

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super initWithAttributes:attributes];
    if (!self) {
        return nil;
    }
    
    //@property (readonly) TSJavelinAPIAgency *agency;
    //@property (readonly) TSJavelinAPIUser *agencyDispatcher;
    _message = [attributes valueForKey:@"message"];
    _timeStamp = [self reformattedTimeStamp:[attributes valueForKey:@"last_modified"]];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    
    [coder encodeObject:_message forKey:@"message"];
    [coder encodeObject:_timeStamp forKey:@"timeStamp"];
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _message = [coder decodeObjectForKey:@"message"];
        _timeStamp = [coder decodeObjectForKey:@"timeStamp"];
    }
    return self;
}

@end
