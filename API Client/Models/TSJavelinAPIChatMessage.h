//
//  TSJavelinAPIChatMessage.h
//  Javelin
//
//  Created by Ben Boyd on 10/25/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIBaseModel.h"

@interface TSJavelinAPIChatMessage : TSJavelinAPIBaseModel

@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *messageID;
@property (nonatomic, assign) NSUInteger alertID;
@property (nonatomic, assign) NSUInteger senderID;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, assign) NSString *senderName;
@property (nonatomic, strong) NSDate *timestamp;

+ (instancetype)chatMessageWithMessage:(NSString *)message;
- (instancetype)initWithAttributes:(NSDictionary *)attributes;
- (instancetype)initWithAttributesFromDynamoDB:(NSDictionary *)attributes;

@end
