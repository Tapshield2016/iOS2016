//
//  TSJavelinAPIBaseModel.h
//  Javelin
//
//  Created by Ben Boyd on 10/25/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSJavelinAPIBaseModel : NSObject

@property (nonatomic, assign) NSUInteger identifier;
@property (nonatomic, strong) NSString *url;

- (id)initWithAttributes:(NSDictionary *)attributes;
- (instancetype)initWithOnlyURLAttribute:(NSDictionary *)attributes forKey:(NSString *)key;

@end
