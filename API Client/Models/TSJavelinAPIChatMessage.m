//
//  TSJavelinAPIChatMessage.m
//  Javelin
//
//  Created by Ben Boyd on 10/25/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIChatMessage.h"
#import "TSJavelinAPIClient.h"
#import "TSJavelinAPIAlert.h"
#import "TSJavelinAlertManager.h"
#import "TSJavelinAPIAuthenticationManager.h"
#import "TSJavelinAPIUser.h"
#import "TSJavelinAPIUtilities.h"
#import <AmazonDynamoDBClient.h>

@implementation TSJavelinAPIChatMessage

// alert ID, timestamp, message, sender ID
+ (instancetype)chatMessageWithMessage:(NSString *)message {
    TSJavelinAPIChatMessage *chatMessage = [[TSJavelinAPIChatMessage alloc] init];
    
    chatMessage.message = message;
    chatMessage.alertID = [[[TSJavelinAPIClient sharedClient] alertManager] activeAlert].identifier;
    chatMessage.senderID = [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].identifier;
    chatMessage.timestamp = [NSDate date];
    chatMessage.messageID = [TSJavelinAPIUtilities uuidString];
    
    return chatMessage;
}

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super initWithAttributes:attributes];
    if (!self) {
        return nil;
    }
    
    //@property (readonly) TSJavelinAPIAlert *alert;
    //@property (readonly) TSJavelinAPIUser *sender;
    _message = [attributes valueForKey:@"message"];
    
    return self;
}

- (instancetype)initWithAttributesFromDynamoDB:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }

    _message = ((DynamoDBAttributeValue *)[attributes valueForKey:@"message"]).s;
    _messageID = ((DynamoDBAttributeValue *)[attributes valueForKey:@"message_id"]).s;
    _alertID = [((DynamoDBAttributeValue *)[attributes valueForKey:@"alert_id"]).n integerValue];
    _senderID = [((DynamoDBAttributeValue *)[attributes valueForKey:@"sender_id"]).n integerValue];
    _timestamp = [NSDate dateWithTimeIntervalSince1970:[((DynamoDBAttributeValue *)[attributes valueForKey:@"timestamp"]).n doubleValue]];

    return self;
}

@end
