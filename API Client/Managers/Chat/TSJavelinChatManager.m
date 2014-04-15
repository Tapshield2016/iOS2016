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

#define LONG_TIMER 45
#define QUICK_TIMER 15

static NSString * const kTSJavelinAPIChatManagerDynamoDBDevelopmentAccessKey = @"AKIAJJX2VM346XUKRROA";
static NSString * const kTSJavelinAPIChatManagerDynamoDBDevelopmentSecretKey = @"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";
static NSString * const kTSJavelinAPIChatManagerDynamoDBDevelopmentTableName = @"chat_messages_dev";

static NSString * const kTSJavelinAPIChatManagerDynamoDBDemoTableName = @"chat_messages_demo";

static NSString * const kTSJavelinAPIChatManagerDynamoDBProductionAccessKey = @"AKIAJ34SY3EAOK6STBBA";
static NSString * const kTSJavelinAPIChatManagerDynamoDBProductionSecretKey = @"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";
static NSString * const kTSJavelinAPIChatManagerDynamoDBProductionTableName = @"chat_messages_prod";

static NSString * const kTSJavelinAPIChatManagerArchivedChatMessages = @"kTSJavelinAPIChatManagerArchivedChatMessages";

// Notifications
NSString * const TSJavelinChatManagerDidReceiveNewChatMessageNotification = @"TSJavelinChatManagerDidReceiveNewChatMessageNotification";

@interface TSJavelinChatManager ()

@property (strong, nonatomic) NSOperationQueue *chatActivityQueue;
@property (strong, nonatomic) AmazonDynamoDBClient *dynamoDB;
@property (strong, nonatomic) NSString *dynamoDBTableName;
@property (strong, nonatomic) NSTimer *getTimer;

@end

@implementation TSJavelinChatManager

static TSJavelinChatManager *_sharedManager = nil;
static dispatch_once_t onceToken;

+ (instancetype)sharedManager {
    if (_sharedManager == nil) {
        dispatch_once(&onceToken, ^{
            _sharedManager = [[TSJavelinChatManager alloc] init];
            _sharedManager.chatMessages = [[TSJavelinChatMessageOrganizer alloc] init];
            _sharedManager.didReceiveAll = NO;
            _sharedManager.quickGetTimerInterval = NO;
            
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



- (void)setQuickGetTimerInterval:(BOOL)quickGetTimerInterval {
    
    _quickGetTimerInterval = quickGetTimerInterval;
    
    if (quickGetTimerInterval) {
        if ([[[TSJavelinAPIClient sharedClient] alertManager] activeAlert].identifier) {
            [self checkForChatMessages];
        }
    }
}

#pragma mark - Sending

- (void)sendChatMessage:(NSString *)message {
    
    TSJavelinAPIChatMessage *chatMessage = [TSJavelinAPIChatMessage chatMessageWithMessage:message];
    [_chatMessages addChatMessage:chatMessage];
    
    if (![[[TSJavelinAPIClient sharedClient] alertManager] activeAlert].identifier) {
        [_chatMessages addChatMessageAwaitingSend:chatMessage];
        return;
    }
    
    [self sendChatMessageForActiveAlert:chatMessage completion:^(ChatMessageStatus status) {
        [_chatMessages updateChatMessage:chatMessage withStatus:status];
    }];
}

- (void)sendAwaitingChatMessages {
    
    for (TSJavelinAPIChatMessage *chatMessage in [_chatMessages.messagesAwaitingSend copy]) {
        chatMessage.alertID = [[TSJavelinAPIClient sharedClient] alertManager].activeAlert.identifier;
        [self sendChatMessageForActiveAlert:chatMessage completion:^(ChatMessageStatus status) {
            [_chatMessages updateChatMessage:chatMessage withStatus:status];
        }];
    }
}

- (void)sendChatMessageForActiveAlert:(TSJavelinAPIChatMessage *)chatMessage completion:(void (^)(ChatMessageStatus status))completion {
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
            completion(kError);
        }
    }
    else {
        
        if (completion) {
            completion(kDelivered);
        }
    }
}


#pragma mark - Receiving

- (void)checkForChatMessages {
    
    [self scheduleCheckMessagesTimer];
    
    if (!_didReceiveAll) {
        [self getChatMessagesForActiveAlert:^(NSArray *chatMessages) {
            if (chatMessages) {
                _didReceiveAll = YES;
                [_chatMessages addChatMessages:chatMessages];
                [[NSNotificationCenter defaultCenter] postNotificationName:TSJavelinChatManagerDidReceiveNewChatMessageNotification object:[chatMessages lastObject]];
            }
            else {
                _didReceiveAll = NO;
            }
            
        }];
    }
    else {
        [self getChatMessagesForActiveAlertSinceTime:[_chatMessages lastReceivedTimeStamp] completion:^(NSArray *chatMessages) {
            if (chatMessages) {
                [_chatMessages addChatMessages:chatMessages];
                [[NSNotificationCenter defaultCenter] postNotificationName:TSJavelinChatManagerDidReceiveNewChatMessageNotification object:[chatMessages lastObject]];
            }
        }];
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
    
    if (![[[TSJavelinAPIClient sharedClient] alertManager] activeAlert].identifier) {
        if (completion) {
            completion(nil);
        }
        return;
    }
    
    DynamoDBQueryRequest *request = [[DynamoDBQueryRequest alloc] initWithTableName:_dynamoDBTableName];
    DynamoDBCondition *condition = [[DynamoDBCondition alloc] init];
    condition.comparisonOperator = @"EQ";
    DynamoDBAttributeValue *alertID = [[DynamoDBAttributeValue alloc] initWithN:[NSString stringWithFormat:@"%lu", (unsigned long)[[[TSJavelinAPIClient sharedClient] alertManager] activeAlert].identifier]];
    [condition addAttributeValueList:alertID];
    request.keyConditions = [NSMutableDictionary dictionaryWithObject:condition forKey:@"alert_id"];
    DynamoDBQueryResponse *response = [_dynamoDB query:request];
    if (completion) {
        
        if (response.error != nil) {
            completion(nil);
            return;
        }
        
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
        
        if (response.error != nil) {
            completion(nil);
            return;
        }
        
        
        if (response && [response.items count] > 0) {
            completion([self chatMessagesArrayFromDynamoDBResponse:response.items]);
        }
        else {
            completion(nil);
        }
    }
}

#pragma mark - Helper Methods

- (void)scheduleCheckMessagesTimer {
    
    NSTimeInterval time = LONG_TIMER;
    if (_quickGetTimerInterval) {
        time = QUICK_TIMER;
    }
    
    [self stopCheckMessagesTimer];
    
    if (!_getTimer) {
        _getTimer = [NSTimer scheduledTimerWithTimeInterval:time
                                                     target:self
                                                   selector:@selector(checkForChatMessages)
                                                   userInfo:nil
                                                    repeats:NO];
    }
}

- (void)stopCheckMessagesTimer {
    
    [_getTimer invalidate];
    _getTimer = nil;
}

- (void)startChatForActiveAlert {
    
    [self sendAwaitingChatMessages];
    [self checkForChatMessages];
}

- (void)receivedNotificationOfNewChatMessageAvailableForActiveAlert:(NSDictionary *)notification {
    
    [self checkForChatMessages];
}

- (void)clearChatMessages {
    
    [self stopCheckMessagesTimer];
    
    if (_chatMessages.messagesAwaitingSend) {
        [_chatMessages.messagesAwaitingSend removeAllObjects];
    }
    if (_chatMessages.allMessages) {
        [_chatMessages.allMessages removeAllObjects];
    }
    
    _didReceiveAll = NO;
}

@end
