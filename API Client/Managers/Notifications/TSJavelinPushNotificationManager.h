//
//  TSJavelinPushNotificationManager.h
//  Javelin
//
//  Created by Ben Boyd on 11/8/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TSJavelinAPIPushNotification.h"

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

+ (void)analyzeNotification:(NSDictionary *)userInfo completion:(void (^)(BOOL matchFound, TSJavelinAPIPushNotification *notification))completion;

@end
