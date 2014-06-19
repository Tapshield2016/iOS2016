//
//  TSJavelinAPIBaseModel.h
//  Javelin
//
//  Created by Ben Boyd on 10/25/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "NSDictionary+ReplaceNull.h"
#import "NSDate+Utilities.h"

@interface TSJavelinAPIBaseModel : NSObject

@property (nonatomic, assign, readonly) NSUInteger identifier;
@property (nonatomic, strong) NSString *url;

- (id)initWithCoder:(NSCoder *)decoder;
- (id)initWithAttributes:(NSDictionary *)attributes;
- (instancetype)initWithOnlyURLAttribute:(NSDictionary *)attributes forKey:(NSString *)key;

- (void)encodeWithCoder:(NSCoder *)encoder;

- (NSDate *)reformattedTimeStamp:(NSString *)dateString;
- (NSDate *)timeFromString:(NSString *)string;

- (NSUInteger)filterIdentifier:(NSString *)url;

@end
