//
//  NSDictionary+ReplaceNull.m
//  TapShield
//
//  Created by Adam Share on 6/17/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "NSDictionary+ReplaceNull.h"

@implementation NSDictionary (ReplaceNull)

- (id)nonNullObjectForKey:(id)aKey {
    
    return [self filterNSNull:[self valueForKey:aKey]];
}

- (id)filterNSNull:(id)object {
    
    if ([object isKindOfClass:[NSNull class]]) {
        return nil;
    }
    return object;
}

@end
