//
//  TSJavelinPushNotificationManager.m
//  Javelin
//
//  Created by Ben Boyd on 11/8/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import "TSJavelinPushNotificationManager.h"
#import "TSJavelinAPIClient.h"

NSString * const TSJavelinPushNotificationManagerDidReceiveAlertAcknowledgementNotification = @"kTSJavelinPushNotificationManagerDidReceiveAlertAcknowledgementNotification";
NSString * const TSJavelinPushNotificationManagerDidReceiveNotificationOfNewChatMessageNotification = @"kTSJavelinPushNotificationManagerDidReceiveNotificationOfNewChatMessageNotification";
NSString * const TSJavelinPushNotificationManagerDidReceiveNotificationOfNewMassAlertNotification = @"kTSJavelinPushNotificationManagerDidReceiveNotificationOfNewMassAlertNotification";

NSString * const TSJavelinPushNotificationManagerDidReceiveNewUserNotifications = @"TSJavelinPushNotificationManagerDidReceiveNewUserNotifications";

NSString * const TSJavelinPushNotificationTypeCrimeReport = @"crime-report";
NSString * const TSJavelinPushNotificationTypeMassAlert = @"mass-alert";
NSString * const TSJavelinPushNotificationTypeChatMessage = @"chat-message-available";
NSString * const TSJavelinPushNotificationTypeAlertReceived = @"alert-received";
NSString * const TSJavelinPushNotificationTypeAlertCompletion = @"alert-completed";

NSString * const TSJavelinPushNotificationTypeEntourageMemberAdded = @"entourage-added";
NSString * const TSJavelinPushNotificationTypeEntourageEmergencyCallAlert = @"entourage-emergency-call";
NSString * const TSJavelinPushNotificationTypeEntourageArrival = @"entourage-arrived";
NSString * const TSJavelinPushNotificationTypeEntourageNonArrival = @"entourage-non-arrival";
NSString * const TSJavelinPushNotificationTypeEntourageYankAlert = @"entourage-yank";

@implementation TSJavelinPushNotificationManager

static TSJavelinPushNotificationManager *_sharedInstance = nil;
static dispatch_once_t predicate;

+ (instancetype)sharedManager {
    
    if (_sharedInstance == nil) {
        dispatch_once(&predicate, ^{
            _sharedInstance = [[self alloc] init];
        });
    }
    return _sharedInstance;
}

+ (void)analyzeNotification:(NSDictionary *)userInfo completion:(void (^)(BOOL matchFound, TSJavelinAPIPushNotification *notification))completion {
    
    TSJavelinAPIPushNotification *notification = [[TSJavelinAPIPushNotification alloc] initWithAttributes:userInfo];
    
    if (notification.alertType && notification.alertID) {
        if (notification.alertType == TSJavelinPushNotificationTypeAlertReceived) {
            NSLog(@"Our alert was acknowledged! - %@", notification.alertType);
            NSLog(@"Alert ID: %@", notification.alertID);
            if (completion) {
                completion(YES, notification);
            }
            [[TSJavelinAPIClient sharedClient] alertReceiptReceivedForAlertWithURL:notification.alertUrl];
        }
        else if (notification.alertType == TSJavelinPushNotificationTypeChatMessage) {
            NSLog(@"New chat message available! - %@", notification.alertType);
            NSLog(@"Alert ID: %@", notification.alertID);
            
            if (completion) {
                completion(YES, notification);
            }
            [[TSJavelinAPIClient sharedClient] receivedNotificationOfNewChatMessageAvailableForActiveAlert:notification];
            [[NSNotificationCenter defaultCenter] postNotificationName: TSJavelinPushNotificationManagerDidReceiveNotificationOfNewChatMessageNotification
                                                                object:notification];
        }
        else if (notification.alertType == TSJavelinPushNotificationTypeAlertCompletion) {
            NSLog(@"New chat message available! - %@", notification.alertType);
            NSLog(@"Alert ID: %@", notification.alertID);
            
            [[TSJavelinAPIClient sharedClient] receivedNotificationOfNewChatMessageAvailableForActiveAlert:notification];
            [[NSNotificationCenter defaultCenter] postNotificationName: TSJavelinPushNotificationManagerDidReceiveNotificationOfNewChatMessageNotification
                                                                object:notification];
            
            if (completion) {
                completion(YES, notification);
            }
            
            [[TSJavelinAPIClient sharedClient] alertCompletionReceivedForAlertURL:notification.alertUrl];
        }
        else if (notification.alertType == TSJavelinPushNotificationTypeMassAlert) {
            NSLog(@"New mass alert! - %@", notification.alertType);
            NSLog(@"Alert ID: %@", notification.alertID);
            if (completion) {
                completion(YES, notification);
            }
            [[TSJavelinAPIClient sharedClient] receivedNotificationOfNewMassAlert:notification];
            [[NSNotificationCenter defaultCenter] postNotificationName: TSJavelinPushNotificationManagerDidReceiveNotificationOfNewMassAlertNotification
                                                                object:notification];
        }
        else if (notification.alertType == TSJavelinPushNotificationTypeCrimeReport) {
            NSLog(@"New crime report! - %@", notification.alertType);
            NSLog(@"Alert ID: %@", notification.alertID);
            if (completion) {
                completion(YES, notification);
            }
            [[TSJavelinAPIClient sharedClient] receivedNotificationOfNewMassAlert:notification];
            [[NSNotificationCenter defaultCenter] postNotificationName: TSJavelinPushNotificationManagerDidReceiveNotificationOfNewMassAlertNotification
                                                                object:notification];
        }
        else if (notification.alertType == TSJavelinPushNotificationTypeEntourageYankAlert ||
                 notification.alertType == TSJavelinPushNotificationTypeEntourageArrival ||
                 notification.alertType == TSJavelinPushNotificationTypeEntourageEmergencyCallAlert ||
                 notification.alertType == TSJavelinPushNotificationTypeEntourageNonArrival) {
            
            if (completion) {
                completion(YES, notification);
            }
            
            [[TSJavelinPushNotificationManager sharedManager] getNewUserNotifications:^(NSArray *notifications) {
                [[NSNotificationCenter defaultCenter] postNotificationName:TSJavelinPushNotificationManagerDidReceiveNewUserNotifications
                                                                    object:notifications];
            }];
        }
        else {
            if (completion) {
                completion(NO, notification);
            }
        }
        
        return;
        
    }
    else if (completion) {
        completion(NO, nil);
    }
}


- (void)getNewUserNotifications:(void(^)(NSArray *notifications))completion {
    
    [[TSJavelinAPIClient sharedClient] getLatestUserNotifications:^(NSArray *notifications) {
        [self newNotifications:notifications];
        
        if (completion) {
            completion(self.sortedNotificationsArray);
        }
    }];
}

- (void)newNotifications:(NSArray *)notifications {
    
    NSUInteger countNew = 0;
    
    if (!_userNotificationsDictionary) {
        _userNotificationsDictionary = [[NSMutableDictionary alloc] initWithCapacity:5];
    }
    
    for (TSJavelinAPIUserNotification *note in notifications) {
        [_userNotificationsDictionary setObject:note forKey:note.url];
        if (!note.read) {
            countNew++;
        }
    }
    
    self.notificationsNewCount = countNew;
}

- (NSMutableArray *)sortedNotificationsArray {
    
    if (!_userNotificationsDictionary) {
        return nil;
    }
    return [self sortUserNotificationsByCreationDate:[[NSMutableArray alloc] initWithArray:_userNotificationsDictionary.allValues]];
}

- (NSMutableArray *)sortUserNotificationsByCreationDate:(NSMutableArray *)notifications {
    
    NSSortDescriptor *dateSort = [[NSSortDescriptor alloc] initWithKey:@"creationDate" ascending:NO];
    [notifications sortUsingDescriptors:@[dateSort]];
    return notifications;
}

- (void)readNotification:(TSJavelinAPIUserNotification *)notification completion:(void (^)(BOOL read))completion {
    
    if (!notification.read) {
        self.notificationsNewCount--;
    }
    
    [[TSJavelinAPIClient sharedClient] markRead:notification completion:completion];
}


- (void)deleteNotification:(TSJavelinAPIUserNotification *)notification completion:(void (^)(BOOL read))completion {
    
    [[TSJavelinAPIClient sharedClient] removeUrl:notification.url completion:completion];
    [_userNotificationsDictionary removeObjectForKey:notification.url];
}


@end
