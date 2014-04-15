//
//  TSChatMessageArray.h
//  TapShield
//
//  Created by Adam Share on 4/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSJavelinAPIChatMessage.h"

@interface TSJavelinChatMessageOrganizer : NSObject

@property (strong, nonatomic) NSMutableOrderedSet *allMessages;
@property (strong, nonatomic) NSMutableArray *messagesAwaitingSend;

- (void)addChatMessage:(TSJavelinAPIChatMessage *)chatMessage;
- (void)addChatMessageAwaitingSend:(TSJavelinAPIChatMessage *)chatMessage;
- (void)addChatMessages:(NSArray *)messageArray;
- (void)updateChatMessage:(TSJavelinAPIChatMessage *)chatMessage withStatus:(ChatMessageStatus)status;
- (NSDate *)lastReceivedTimeStamp;

@end
