//
//  NSNull+JSON.h
//  TapShield
//
//  Created by Adam Share on 7/18/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNull (JSON)

- (NSUInteger)length;

- (NSInteger)integerValue;

- (float)floatValue;

- (NSString *)description;

- (NSArray *)componentsSeparatedByString:(NSString *)separator;

- (id)objectForKey:(id)key;

- (BOOL)boolValue;

@end
