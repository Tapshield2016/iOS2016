//
//  TSJavelinChatManager.m
//  Javelin
//
//  Created by Ben Boyd on 11/7/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import "TSJavelinChatManager.h"
#import "TSJavelinAPIClient.h"
#import "TSJavelinAPIChatMessage.h"
#import "TSJavelinAPIAlert.h"
#import <AmazonDynamoDBClient.h>

static NSString * const kTSJavelinAPIChatManagerDynamoDBDevelopmentAccessKey = @"AKIAJJX2VM346XUKRROA";
static NSString * const kTSJavelinAPIChatManagerDynamoDBDevelopmentSecretKey = @"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";
static NSString * const kTSJavelinAPIChatManagerDynamoDBDevelopmentTableName = @"chat_messages_dev";

static NSString * const kTSJavelinAPIChatManagerDynamoDBDemoTableName = @"chat_messages_demo";

static NSString * const kTSJavelinAPIChatManagerDynamoDBProductionAccessKey = @"AKIAJ34SY3EAOK6STBBA";
static NSString * const kTSJavelinAPIChatManagerDynamoDBProductionSecretKey = @"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";
static NSString * const kTSJavelinAPIChatManagerDynamoDBProductionTableName = @"chat_messages_prod";

// Notifications
NSString * const kTSJavelinChatManagerDidReceiveNotificationOfNewChatMessageNotification = @"kTSJavelinChatManagerDidReceiveNotificationOfNewChatMessageNotification";

@interface TSJavelinChatManager ()

@property (nonatomic, strong) AmazonDynamoDBClient *dynamoDB;
@property (nonatomic, strong) NSString *dynamoDBTableName;

@end

@implementation TSJavelinChatManager

static TSJavelinChatManager *_sharedManager = nil;
static dispatch_once_t onceToken;

+ (instancetype)sharedManager {
    if (_sharedManager == nil) {
        dispatch_once(&onceToken, ^{
            _sharedManager = [[TSJavelinChatManager alloc] init];
            AmazonCredentials *credentials;
#ifdef DEV
            credentials = [[AmazonCredentials alloc] initWithAccessKey:kTSJavelinAPIChatManagerDynamoDBDevelopmentAccessKey
                                                         withSecretKey:kTSJavelinAPIChatManagerDynamoDBDevelopmentSecretKey];
            _sharedManager.dynamoDBTableName = kTSJavelinAPIChatManagerDynamoDBDevelopmentTableName;
#elif DEMO
            credentials = [[AmazonCredentials alloc] initWithAccessKey:kTSJavelinAPIChatManagerDynamoDBDevelopmentAccessKey
                                                         withSecretKey:kTSJavelinAPIChatManagerDynamoDBDevelopmentSecretKey];
            _sharedManager.dynamoDBTableName = kTSJavelinAPIChatManagerDynamoDBDemoTableName;

#elif APP_STORE
            credentials = [[AmazonCredentials alloc] initWithAccessKey:kTSJavelinAPIChatManagerDynamoDBProductionAccessKey
                                                         withSecretKey:kTSJavelinAPIChatManagerDynamoDBProductionSecretKey];
            _sharedManager.dynamoDBTableName = kTSJavelinAPIChatManagerDynamoDBProductionTableName;
            
#endif
            _sharedManager.dynamoDB = [[AmazonDynamoDBClient alloc] initWithCredentials:credentials];
        });
    }
    
    return _sharedManager;
}

- (void)sendChatMessageForActiveAlert:(TSJavelinAPIChatMessage *)chatMessage completion:(void (^)(TSJavelinAPIChatMessage *sentChatMessage))completion {
    // alert ID, timestamp, message, sender ID

    NSMutableDictionary *messageDictionary = [[NSMutableDictionary alloc] initWithCapacity:4];
    messageDictionary[@"message"] = [[DynamoDBAttributeValue alloc] initWithS:chatMessage.message];
    messageDictionary[@"message_id"] = [[DynamoDBAttributeValue alloc] initWithS:chatMessage.messageID];
    messageDictionary[@"alert_id"] = [[DynamoDBAttributeValue alloc] initWithN:[NSString stringWithFormat:@"%lu", (unsigned long)chatMessage.alertID]];
    messageDictionary[@"sender_id"] = [[DynamoDBAttributeValue alloc] initWithN:[NSString stringWithFormat:@"%lu", (unsigned long)chatMessage.senderID]];
    messageDictionary[@"timestamp"] = [[DynamoDBAttributeValue alloc] initWithN:[NSString stringWithFormat:@"%f", [chatMessage.timestamp timeIntervalSince1970]]];

    DynamoDBPutItemRequest *request = [[DynamoDBPutItemRequest alloc] initWithTableName:_dynamoDBTableName
                                                                                andItem:messageDictionary];
    DynamoDBPutItemResponse *response = [_dynamoDB putItem:request];
    if(response.error != nil) {
        NSLog(@"Error sending chat message: %@", response.error);
        if (completion) {
            completion(NO);
        }
    }
    else {
        if (completion) {
            completion(chatMessage);
        }
    }
}


- (NSArray *)chatMessagesArrayFromDynamoDBResponse:(NSArray *)responseItems {
    NSMutableArray *messages = [[NSMutableArray alloc] initWithCapacity:24];
    for (NSDictionary *item in responseItems) {
        TSJavelinAPIChatMessage *chatMessage = [[TSJavelinAPIChatMessage alloc] initWithAttributesFromDynamoDB:item];
        [messages addObject:chatMessage];
    }

    return messages;
}

- (void)getChatMessagesForActiveAlert:(void (^)(NSArray *chatMessages))completion {
    DynamoDBQueryRequest *request = [[DynamoDBQueryRequest alloc] initWithTableName:_dynamoDBTableName];
    DynamoDBCondition *condition = [[DynamoDBCondition alloc] init];
    condition.comparisonOperator = @"EQ";
    DynamoDBAttributeValue *alertID = [[DynamoDBAttributeValue alloc] initWithN:[NSString stringWithFormat:@"%lu", (unsigned long)[[[TSJavelinAPIClient sharedClient] alertManager] activeAlert].identifier]];
    [condition addAttributeValueList:alertID];
    request.keyConditions = [NSMutableDictionary dictionaryWithObject:condition forKey:@"alert_id"];
    DynamoDBQueryResponse *response = [_dynamoDB query:request];
    if (completion) {
        if (response && [response.items count] > 0) {
            completion([self chatMessagesArrayFromDynamoDBResponse:response.items]);
        }
        else {
            completion(nil);
        }
    }
}

- (void)getChatMessagesForActiveAlertSinceTime:(NSDate *)dateTime completion:(void (^)(NSArray *chatMessages))completion {
    DynamoDBQueryRequest *request = [[DynamoDBQueryRequest alloc] initWithTableName:_dynamoDBTableName];

    DynamoDBCondition *alertIDCondition = [[DynamoDBCondition alloc] init];
    alertIDCondition.comparisonOperator = @"EQ";
    DynamoDBAttributeValue *alertID = [[DynamoDBAttributeValue alloc] initWithN:[NSString stringWithFormat:@"%lu", (unsigned long)[[[TSJavelinAPIClient sharedClient] alertManager] activeAlert].identifier]];
    [alertIDCondition addAttributeValueList:alertID];

    DynamoDBCondition *timestampCondition = [[DynamoDBCondition alloc] init];
    timestampCondition.comparisonOperator = @"GE";
    DynamoDBAttributeValue *timestamp = [[DynamoDBAttributeValue alloc] initWithN:[NSString stringWithFormat:@"%f", [dateTime timeIntervalSince1970]]];
    [timestampCondition addAttributeValueList:timestamp];
    
    request.keyConditions = [[NSMutableDictionary alloc] initWithObjects:@[alertIDCondition, timestampCondition]
                                                                 forKeys:@[@"alert_id", @"timestamp"]];
    DynamoDBQueryResponse *response = [_dynamoDB query:request];
    if (completion) {
        if (response && [response.items count] > 0) {
            completion([self chatMessagesArrayFromDynamoDBResponse:response.items]);
        }
        else {
            completion(nil);
        }
    }
}


- (void)receivedNotificationOfNewChatMessageAvailableForActiveAlert:(NSDictionary *)notification {
    [[NSNotificationCenter defaultCenter] postNotificationName:kTSJavelinChatManagerDidReceiveNotificationOfNewChatMessageNotification object:notification];
}

@end
