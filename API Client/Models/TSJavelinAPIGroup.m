//
//  TSJavelinAPIGroup.m
//  Javelin
//
//  Created by Ben Boyd on 10/25/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIGroup.h"

@implementation TSJavelinAPIGroup

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super initWithAttributes:attributes];
    if (!self) {
        return nil;
    }
    
    _name = [attributes valueForKey:@"name"];
    
    return self;
}

@end
