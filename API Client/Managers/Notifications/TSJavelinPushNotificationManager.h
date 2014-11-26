//
//  TSJavelinPushNotificationManager.h
//  Javelin
//
//  Created by Ben Boyd on 11/8/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSJavelinAPIPushNotification.h"

@class TSJavelinAPIUserNotification;

extern NSString * const TSJavelinPushNotificationManagerDidReceiveAlertAcknowledgementNotification;
extern NSString * const TSJavelinPushNotificationManagerDidReceiveNotificationOfNewChatMessageNotification;
extern NSString * const TSJavelinPushNotificationManagerDidReceiveNotificationOfNewMassAlertNotification;

extern NSString * const TSJavelinPushNotificationTypeCrimeReport;
extern NSString * const TSJavelinPushNotificationTypeMassAlert;
extern NSString * const TSJavelinPushNotificationTypeChatMessage;
extern NSString * const TSJavelinPushNotificationTypeAlertReceived;
extern NSString * const TSJavelinPushNotificationTypeAlertCompletion;


extern NSString * const TSJavelinPushNotificationTypeEntourageMemberAdded;
extern NSString * const TSJavelinPushNotificationTypeEntourageEmergencyCallAlert;
extern NSString * const TSJavelinPushNotificationTypeEntourageArrival;
extern NSString * const TSJavelinPushNotificationTypeEntourageNonArrival;
extern NSString * const TSJavelinPushNotificationTypeEntourageYankAlert;

@interface TSJavelinPushNotificationManager : NSObject

@property (strong, nonatomic) NSMutableDictionary *userNotificationsDictionary;

@property (strong, nonatomic) NSMutableArray *sortedNotificationsArray;

+ (instancetype)sharedManager;

- (void)getNewUserNotifications:(void(^)(NSArray *notifications))completion;

+ (void)analyzeNotification:(NSDictionary *)userInfo completion:(void (^)(BOOL matchFound, TSJavelinAPIPushNotification *notification))completion;

- (void)readNotification:(TSJavelinAPIUserNotification *)notification completion:(void (^)(BOOL read))completion;
- (void)deleteNotification:(TSJavelinAPIUserNotification *)notification completion:(void (^)(BOOL read))completion;

@end
