//
//  TSChatMessageArray.m
//  TapShield
//
//  Created by Adam Share on 4/11/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSJavelinChatMessageOrganizer.h"
#import "TSJavelinAPIClient.h"
#import <AVFoundation/AVFoundation.h>

@implementation TSJavelinChatMessageOrganizer

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initAllMessage];
    }
    return self;
}

- (void)initAllMessage {
    self.allMessages = [[NSMutableOrderedSet alloc] initWithCapacity:10];
}

- (void)clearChatMessage {
    [self initAllMessage];
}

- (void)addChatMessage:(TSJavelinAPIChatMessage *)chatMessage {
    
    if (!chatMessage) {
        return;
    }
    
    [_allMessages addObject:chatMessage];
    [self sortByTimestamp:_allMessages];
}

- (void)addChatMessageAwaitingSend:(TSJavelinAPIChatMessage *)chatMessage {
    
    if (!_messagesAwaitingSend) {
        _messagesAwaitingSend = [[NSMutableArray alloc] initWithCapacity:1];
    }
    
    [_messagesAwaitingSend addObject:chatMessage];
}

- (void)addChatMessages:(NSArray *)messageArray {
    
    if (!messageArray) {
        return;
    }
    
    NSIndexSet *indexSet = [[_allMessages copy]indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        TSJavelinAPIChatMessage *chatMessage = (TSJavelinAPIChatMessage *)obj;
        
        for (TSJavelinAPIChatMessage *oldMessage in messageArray) {
            if ([chatMessage.messageID isEqualToString:oldMessage.messageID]) {
                return YES;
            }
        }
        return NO;
    }];
    
    if (indexSet.count < messageArray.count) {
        AudioServicesPlaySystemSound( kSystemSoundID_Vibrate );
    }
    
    if (indexSet.count != 0) {
        [_allMessages removeObjectsAtIndexes:indexSet];
    }
    
    [_allMessages addObjectsFromArray:messageArray];
    [self sortByTimestamp:_allMessages];
}

- (void)updateChatMessage:(TSJavelinAPIChatMessage *)chatMessage withStatus:(ChatMessageStatus)status {
    
    [_allMessages removeObject:chatMessage];
    
    chatMessage.status = status;
    
    [self addChatMessage:chatMessage];
}

- (NSMutableOrderedSet *)sortByTimestamp:(NSMutableOrderedSet *)set {
    
    NSSortDescriptor *dateSort = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    [set sortUsingDescriptors:@[dateSort]];
    return set;
}

- (NSDate *)lastReceivedTimeStamp {
    
    NSPredicate *removeReceived = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        TSJavelinAPIChatMessage *chatMessage = (TSJavelinAPIChatMessage *)evaluatedObject;
        if (chatMessage.status != kReceived && chatMessage.status != kError) {
            return YES;
        }
        return NO;
    }];
    
    NSPredicate *onlyDispatcherMessages = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        TSJavelinAPIChatMessage *chatMessage = (TSJavelinAPIChatMessage *)evaluatedObject;
        if (chatMessage.senderID != [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].identifier) {
            return YES;
        }
        return NO;
    }];
    NSMutableOrderedSet *messagesNeedingUpdate = [NSMutableOrderedSet orderedSetWithOrderedSet:[[_allMessages copy] filteredOrderedSetUsingPredicate:removeReceived]];
    NSMutableOrderedSet *messagesFromDispatcher = [NSMutableOrderedSet orderedSetWithOrderedSet:[[_allMessages copy] filteredOrderedSetUsingPredicate:onlyDispatcherMessages]];
    
    messagesNeedingUpdate = [self sortByTimestamp:messagesNeedingUpdate];
    messagesFromDispatcher = [self sortByTimestamp:messagesFromDispatcher];
    
    NSDate *date = ((TSJavelinAPIChatMessage *)[_allMessages lastObject]).timestamp;
    
    TSJavelinAPIChatMessage *earliestNeedingUpdate = [messagesNeedingUpdate firstObject];
    TSJavelinAPIChatMessage *dispatcherLatest = [messagesFromDispatcher lastObject];
    
    if (!earliestNeedingUpdate && !dispatcherLatest) {
        return date;
    }
    
    if (!earliestNeedingUpdate) {
        date = dispatcherLatest.timestamp;
    }
    else if (!dispatcherLatest){
        date = earliestNeedingUpdate.timestamp;
    }
    else {
        NSMutableOrderedSet *compare = [NSMutableOrderedSet orderedSetWithObjects:[messagesNeedingUpdate firstObject], [messagesFromDispatcher lastObject], nil];
        TSJavelinAPIChatMessage *checkFromMessage = [[self sortByTimestamp:compare] firstObject];
        date = checkFromMessage.timestamp;
    }
    
    
    return date;
}

@end
