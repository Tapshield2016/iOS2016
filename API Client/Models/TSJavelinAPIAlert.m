//
//  TSJavelinAPIAlert.m
//  Javelin
//
//  Created by Ben Boyd on 10/25/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIAlert.h"

@implementation TSJavelinAPIAlert

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super initWithAttributes:attributes];
    if (!self) {
        return nil;
    }
    
    //@property (nonatomic, strong) TSJavelinAPIAgency *agency;
    //@property (nonatomic, strong) TSJavelinAPIUser *agencyDispatcher;
    //@property (nonatomic, strong) TSJavelinAPIUser *agencyUser;
    _locationAddress = [attributes valueForKey:@"location_address"];
    _alertStatus = [attributes valueForKey:@"status"];

    if (![[attributes objectForKey:@"location"] isKindOfClass:[NSNull class]]) {
        _location = [attributes objectForKey:@"location"];
    }
    
    return self;
}

@end
