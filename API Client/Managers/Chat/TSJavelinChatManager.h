//
//  TSJavelinChatManager.h
//  Javelin
//
//  Created by Ben Boyd on 11/7/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSJavelinAPIChatMessage.h"

extern NSString * const kTSJavelinChatManagerDidReceiveNotificationOfNewChatMessageNotification;

@interface TSJavelinChatManager : NSObject

+ (instancetype)sharedManager;

- (void)sendChatMessageForActiveAlert:(TSJavelinAPIChatMessage *)chatMessage completion:(void (^)(TSJavelinAPIChatMessage *sentChatMessage))completion;
- (void)getChatMessagesForActiveAlert:(void (^)(NSArray *chatMessages))completion;
- (void)getChatMessagesForActiveAlertSinceTime:(NSDate *)dateTime completion:(void (^)(NSArray *chatMessages))completion;
- (void)receivedNotificationOfNewChatMessageAvailableForActiveAlert:(NSDictionary *)notification;

@end
