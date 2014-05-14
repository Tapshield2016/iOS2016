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

extern NSString * const TSJavelinChatManagerDidReceiveNewChatMessageNotification;
extern NSString * const TSJavelinChatManagerDidUpdateChatMessageNotification;

@interface TSJavelinChatManager : NSObject

@property (strong, nonatomic) TSJavelinChatMessageOrganizer *chatMessages;
@property (assign, nonatomic) BOOL didReceiveAll;
@property (assign, nonatomic) BOOL quickGetTimerInterval;
@property (assign, nonatomic) NSUInteger unreadMessages;

+ (instancetype)sharedManager;

- (void)startChatForActiveAlert;
- (void)clearChatMessages;

- (void)sendChatMessage:(NSString *)message;
- (void)sendChatMessageForActiveAlert:(TSJavelinAPIChatMessage *)chatMessage completion:(void (^)(ChatMessageStatus status))completion;
- (void)getChatMessagesForActiveAlert:(void (^)(NSArray *chatMessages))completion;
- (void)getChatMessagesForActiveAlertSinceTime:(NSDate *)dateTime completion:(void (^)(NSArray *chatMessages))completion;
- (void)receivedNotificationOfNewChatMessageAvailableForActiveAlert:(NSDictionary *)notification;

@end
