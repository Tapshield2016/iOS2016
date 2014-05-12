//
//  TSJavelinAPIBaseModel.h
//  Javelin
//
//  Created by Ben Boyd on 10/25/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSJavelinAPIBaseModel : NSObject

@property (nonatomic, assign, readonly) NSUInteger identifier;
@property (nonatomic, strong) NSString *url;

- (id)initWithCoder:(NSCoder *)decoder;
- (id)initWithAttributes:(NSDictionary *)attributes;
- (instancetype)initWithOnlyURLAttribute:(NSDictionary *)attributes forKey:(NSString *)key;

- (void)encodeWithCoder:(NSCoder *)encoder;

- (NSDate *)reformattedTimeStamp:(NSDictionary *)attributes;

@end
