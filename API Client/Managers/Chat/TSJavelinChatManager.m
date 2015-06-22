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
#import <AWSDynamoDB/AWSDynamoDB.h>

#define LONG_TIMER 45
#define QUICK_TIMER 15

static NSString * const kTSJavelinAPIChatManagerDynamoDBDevelopmentAccessKey = @"AKIAJJX2VM346XUKRROA";
static NSString * const kTSJavelinAPIChatManagerDynamoDBDevelopmentSecretKey = @"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";
static NSString * const kTSJavelinAPIChatManagerDynamoDBDevelopmentTableName = @"chat_messages_dev";

static NSString * const kTSJavelinAPIChatManagerDynamoDBKey = @"kTSJavelinAPIChatManagerDynamoDBKey";

static NSString * const kTSJavelinAPIChatManagerDynamoDBDemoTableName = @"chat_messages_demo";

static NSString * const kTSJavelinAPIChatManagerDynamoDBProductionAccessKey = @"AKIAJ34SY3EAOK6STBBA";
static NSString * const kTSJavelinAPIChatManagerDynamoDBProductionSecretKey = @"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";
static NSString * const kTSJavelinAPIChatManagerDynamoDBProductionTableName = @"chat_messages_prod";

static NSString * const kTSJavelinAPIChatManagerArchivedChatMessages = @"kTSJavelinAPIChatManagerArchivedChatMessages";

// Notifications
NSString * const TSJavelinChatManagerDidUpdateChatMessageNotification = @"TSJavelinChatManagerDidUpdateChatMessageNotification";
NSString * const TSJavelinChatManagerDidReceiveNewChatMessageNotification = @"TSJavelinChatManagerDidReceiveNewChatMessageNotification";

@interface TSJavelinChatManager ()

@property (strong, nonatomic) NSOperationQueue *chatActivityQueue;
@property (strong, nonatomic) AWSDynamoDB *dynamoDB;
@property (strong, nonatomic) NSString *dynamoDBTableName;
@property (strong, nonatomic) NSTimer *getTimer;
@property (assign, nonatomic) NSUInteger previousCount;

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
            _sharedManager.unreadMessages = 0;
            
            AWSServiceConfiguration *configuration;
            AWSStaticCredentialsProvider *credentialsProvider;
#ifdef DEV
            
            credentialsProvider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:kTSJavelinAPIChatManagerDynamoDBDevelopmentAccessKey
                                                                               secretKey:kTSJavelinAPIChatManagerDynamoDBDevelopmentSecretKey];
            configuration = [[AWSServiceConfiguration  alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
            _sharedManager.dynamoDBTableName = kTSJavelinAPIChatManagerDynamoDBDevelopmentTableName;
#elif DEMO
            credentialsProvider = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:kTSJavelinAPIChatManagerDynamoDBDevelopmentAccessKey
                                                                               secretKey:kTSJavelinAPIChatManagerDynamoDBDevelopmentSecretKey];
            configuration = [[AWSServiceConfiguration  alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
            _sharedManager.dynamoDBTableName = kTSJavelinAPIChatManagerDynamoDBDemoTableName;
            
#elif APP_STORE
            credentialsProvider = [[AWSStaticCredentialsProvider  alloc] initWithAccessKey:kTSJavelinAPIChatManagerDynamoDBProductionAccessKey
                                                                               secretKey:kTSJavelinAPIChatManagerDynamoDBProductionSecretKey];
            configuration = [[AWSServiceConfiguration  alloc] initWithRegion:AWSRegionUSEast1 credentialsProvider:credentialsProvider];
            _sharedManager.dynamoDBTableName = kTSJavelinAPIChatManagerDynamoDBProductionTableName;
            
#endif
            [AWSDynamoDB registerDynamoDBWithConfiguration:configuration forKey:kTSJavelinAPIChatManagerDynamoDBKey];
            _sharedManager.dynamoDB = [AWSDynamoDB DynamoDBForKey:kTSJavelinAPIChatManagerDynamoDBKey];
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
    AWSDynamoDBAttributeValue *message = [[AWSDynamoDBAttributeValue alloc] init];
    message.S = chatMessage.message;
    messageDictionary[@"message"] = message;
    
    AWSDynamoDBAttributeValue *messageID = [[AWSDynamoDBAttributeValue alloc] init];
    messageID.S = chatMessage.messageID;
    messageDictionary[@"message_id"] = messageID;
    
    AWSDynamoDBAttributeValue *alertID = [[AWSDynamoDBAttributeValue alloc] init];
    alertID.N = [NSString stringWithFormat:@"%lu", (unsigned long)chatMessage.alertID];
    messageDictionary[@"alert_id"] = alertID;
    
    AWSDynamoDBAttributeValue *senderID = [[AWSDynamoDBAttributeValue alloc] init];
    senderID.N = [NSString stringWithFormat:@"%lu", (unsigned long)chatMessage.senderID];
    messageDictionary[@"sender_id"] = senderID;
    
    AWSDynamoDBAttributeValue *timestamp = [[AWSDynamoDBAttributeValue alloc] init];
    timestamp.N = [NSString stringWithFormat:@"%f", [chatMessage.timestamp timeIntervalSince1970]];
    messageDictionary[@"timestamp"] = timestamp;

    AWSDynamoDBPutItemInput *itemInput = [[AWSDynamoDBPutItemInput alloc] init];
    itemInput.tableName = _dynamoDBTableName;
    itemInput.item = messageDictionary;
    
    [[_dynamoDB putItem:itemInput] continueWithBlock:^id(AWSTask *task) {
        if(task.error) {
            NSLog(@"Error sending chat message: %@", task.error);
            
            if (completion) {
                completion(kError);
            }
        }
        else {
            
            if (completion) {
                completion(kDelivered);
            }
        }
        
        return nil;
    }];
//    DynamoDBPutItemRequest *request = [[DynamoDBPutItemRequest alloc] initWithTableName:_dynamoDBTableName
//                                                                                andItem:messageDictionary];
//    DynamoDBPutItemResponse *response = [_dynamoDB putItem:request];
    
    
    
}


#pragma mark - Receiving

- (void)checkForChatMessages {
    
    [self scheduleCheckMessagesTimer];
    
    if (!_didReceiveAll) {
        [self getChatMessagesForActiveAlert:^(NSArray *chatMessages) {
            if (chatMessages) {
                _didReceiveAll = YES;
                [_chatMessages addChatMessages:chatMessages];
                [self newMessagesCount];
                [[NSNotificationCenter defaultCenter] postNotificationName:TSJavelinChatManagerDidUpdateChatMessageNotification object:[chatMessages lastObject]];
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
                [self newMessagesCount];
                [[NSNotificationCenter defaultCenter] postNotificationName:TSJavelinChatManagerDidUpdateChatMessageNotification object:[chatMessages lastObject]];
            }
        }];
    }
}

- (void)newMessagesCount {
    NSUInteger newMessageCount = _chatMessages.allMessages.count - _previousCount;
    if (newMessageCount > 0) {
        [TSJavelinChatManager sharedManager].unreadMessages += newMessageCount;
        _previousCount = _chatMessages.allMessages.count;
        [[NSNotificationCenter defaultCenter] postNotificationName:TSJavelinChatManagerDidReceiveNewChatMessageNotification object:nil];
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
    
    if ([[[TSJavelinAPIClient sharedClient] alertManager] activeAlert].identifier) {
        _currentAlertIdentifier = [[[TSJavelinAPIClient sharedClient] alertManager] activeAlert].identifier;
    }
    
    if (![[[TSJavelinAPIClient sharedClient] alertManager] activeAlert].identifier && !_currentAlertIdentifier) {
        if (completion) {
            completion(nil);
        }
        return;
    }
    
    
    AWSDynamoDBCondition *alertIDCondition = [[AWSDynamoDBCondition alloc] init];
    alertIDCondition.comparisonOperator = AWSDynamoDBComparisonOperatorEQ;
    
    AWSDynamoDBAttributeValue *alertID = [[AWSDynamoDBAttributeValue alloc] init];
    alertID.N = [NSString stringWithFormat:@"%lu", (unsigned long)_currentAlertIdentifier];
    alertIDCondition.attributeValueList = @[alertID];
    
    AWSDynamoDBQueryInput *queryInput = [[AWSDynamoDBQueryInput alloc] init];
    queryInput.tableName = _dynamoDBTableName;
    queryInput.keyConditions = [NSMutableDictionary dictionaryWithObject:alertIDCondition forKey:@"alert_id"];
    
    [[_dynamoDB query:queryInput] continueWithBlock:^id(AWSTask *task) {
        
        if (completion) {
            
            if (task.error) {
                completion(nil);
            }
            else {
                AWSDynamoDBQueryOutput *output = task.result;
                if (output && [output.items count] > 0) {
                    completion([self chatMessagesArrayFromDynamoDBResponse:output.items]);
                }
                else {
                    completion(nil);
                }
            }
        }
        
        return nil;
    }];
    
//    [condition addAttributeValueList:alertID];
//    request.keyConditions = [NSMutableDictionary dictionaryWithObject:condition forKey:@"alert_id"];
//    DynamoDBQueryResponse *response = [_dynamoDB query:request];
    
}

- (void)getChatMessagesForActiveAlertSinceTime:(NSDate *)dateTime completion:(void (^)(NSArray *chatMessages))completion {
    
    AWSDynamoDBCondition *alertIDCondition = [[AWSDynamoDBCondition alloc] init];
    alertIDCondition.comparisonOperator = AWSDynamoDBComparisonOperatorEQ;
    AWSDynamoDBAttributeValue *alertID = [[AWSDynamoDBAttributeValue alloc] init];
    alertID.N = [NSString stringWithFormat:@"%lu", (unsigned long)_currentAlertIdentifier];
    alertIDCondition.attributeValueList = @[alertID];
    
    AWSDynamoDBCondition *timestampCondition = [[AWSDynamoDBCondition alloc] init];
    timestampCondition.comparisonOperator = AWSDynamoDBComparisonOperatorGE;
    AWSDynamoDBAttributeValue *timestamp = [[AWSDynamoDBAttributeValue alloc] init];
    timestamp.N = [NSString stringWithFormat:@"%f", [dateTime timeIntervalSince1970]];
    timestampCondition.attributeValueList = @[timestamp];
    
    
    AWSDynamoDBQueryInput *queryInput = [[AWSDynamoDBQueryInput alloc] init];
    queryInput.tableName = _dynamoDBTableName;
    queryInput.keyConditions = [[NSMutableDictionary alloc] initWithObjects:@[alertIDCondition, timestampCondition]
                                                                    forKeys:@[@"alert_id", @"timestamp"]];
    
    [[_dynamoDB query:queryInput] continueWithBlock:^id(AWSTask *task) {
        
        if (completion) {
            
            if (task.error) {
                completion(nil);
            }
            else {
                AWSDynamoDBQueryOutput *output = task.result;
                if (output && [output.items count] > 0) {
                    completion([self chatMessagesArrayFromDynamoDBResponse:output.items]);
                }
                else {
                    completion(nil);
                }
            }
        }
        
        return nil;
    }];
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

- (void)receivedNotificationOfNewChatMessageAvailableForActiveAlert:(TSJavelinAPIPushNotification *)notification {
    
    [self checkForChatMessages];
}

- (void)clearChatMessages {
    
    [self stopCheckMessagesTimer];
    
    if (_chatMessages.messagesAwaitingSend) {
        [_chatMessages.messagesAwaitingSend removeAllObjects];
    }
    
    [TSJavelinChatManager sharedManager].unreadMessages = 0;
    _didReceiveAll = NO;
}

@end
