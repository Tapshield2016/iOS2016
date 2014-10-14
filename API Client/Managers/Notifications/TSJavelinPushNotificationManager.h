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

@interface TSJavelinPushNotificationManager : NSObject

+ (void)analyzeNotification:(NSDictionary *)userInfo completion:(void (^)(BOOL matchFound, TSJavelinAPIPushNotification *notification))completion;

@end
