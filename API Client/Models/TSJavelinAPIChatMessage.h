//
//  TSJavelinAPIChatMessage.h
//  Javelin
//
//  Created by Ben Boyd on 10/25/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIBaseModel.h"

#define kChatMessageStatusArray @"Received", @"Sending", @"Delivered", @"Error", nil
typedef enum {
    kReceived = 0,
    kSending,
    kDelivered,
    kError,
}ChatMessageStatus;

@interface TSJavelinAPIChatMessage : TSJavelinAPIBaseModel

@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *messageID;
@property (nonatomic, assign) NSUInteger alertID;
@property (nonatomic, assign) NSUInteger senderID;
@property (nonatomic, assign) ChatMessageStatus status;
@property (nonatomic, assign) NSString *senderName;
@property (nonatomic, strong) NSDate *timestamp;

+ (instancetype)chatMessageWithMessage:(NSString *)message;
- (instancetype)initWithAttributes:(NSDictionary *)attributes;
- (instancetype)initWithAttributesFromDynamoDB:(NSDictionary *)attributes;
- (NSString*)chatMessageStatusToString:(ChatMessageStatus)enumValue;

@end
