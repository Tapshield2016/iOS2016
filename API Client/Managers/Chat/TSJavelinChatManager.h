//
//  TSJavelinChatManager.h
//  Javelin
//
//  Created by Ben Boyd on 11/7/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSJavelinChatMessageOrganizer.h"
#import "TSJavelinAPIChatMessage.h"

extern NSString * const TSJavelinChatManagerDidReceiveNotificationOfNewChatMessageNotification;

@interface TSJavelinChatManager : NSObject

@property (strong, nonatomic) TSJavelinChatMessageOrganizer *chatMessages;
@property (assign, nonatomic) BOOL didReceivedAll;
@property (assign, nonatomic) BOOL quickGetTimerInterval;

+ (instancetype)sharedManager;

- (void)startChatForActiveAlert;

- (void)sendChatMessage:(NSString *)message;
- (void)sendChatMessageForActiveAlert:(TSJavelinAPIChatMessage *)chatMessage completion:(void (^)(ChatMessageStatus status))completion;
- (void)getChatMessagesForActiveAlert:(void (^)(NSArray *chatMessages))completion;
- (void)getChatMessagesForActiveAlertSinceTime:(NSDate *)dateTime completion:(void (^)(NSArray *chatMessages))completion;
- (void)receivedNotificationOfNewChatMessageAvailableForActiveAlert:(NSDictionary *)notification;

@end
