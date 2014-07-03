//
//  TSJavelinAPIEmail.m
//  TapShield
//
//  Created by Adam Share on 6/27/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIEmail.h"

@implementation TSJavelinAPIEmail

- (id)initWithAttributes:(NSDictionary *)attributes {
   self = [super init];
    if (self) {
        
        _email = [attributes nonNullObjectForKey:@"email"];
        _isPrimary = [[attributes nonNullObjectForKey:@"is_primary"] boolValue];
        _isActive = [[attributes nonNullObjectForKey:@"is_active"] boolValue];
        _isActivationSent = [[attributes nonNullObjectForKey:@"is_activation_sent"] boolValue];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        _email = [coder decodeObjectForKey:@"email"];
        _isPrimary = [[coder decodeObjectForKey:@"is_primary"] boolValue];
        _isActive = [[coder decodeObjectForKey:@"is_active"] boolValue];
        _isActivationSent = [[coder decodeObjectForKey:@"is_activation_sent"] boolValue];
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [super encodeWithCoder:encoder];
    
    [encoder encodeObject:_email forKey:@"email"];
    [encoder encodeObject:@(_isPrimary) forKey:@"is_primary"];
    [encoder encodeObject:@(_isActive) forKey:@"is_active"];
    [encoder encodeObject:@(_isActivationSent) forKey:@"is_activation_sent"];
}

@end
