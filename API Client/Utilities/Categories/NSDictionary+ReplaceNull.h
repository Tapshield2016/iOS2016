//
//  NSDictionary+ReplaceNull.h
//  TapShield
//
//  Created by Adam Share on 6/17/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (ReplaceNull)

- (id)nonNullObjectForKey:(id)aKey;

@end
