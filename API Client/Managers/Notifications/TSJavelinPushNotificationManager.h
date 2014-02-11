//
//  TSJavelinPushNotificationManager.h
//  Javelin
//
//  Created by Ben Boyd on 11/8/13.
//  Copyright (c) 2013 TapShield, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const TSJavelinPushNotificationManagerDidReceiveAlertAcknowledgementNotification;
extern NSString * const TSJavelinPushNotificationManagerDidReceiveNotificationOfNewChatMessageNotification;
extern NSString * const TSJavelinPushNotificationManagerDidReceiveNotificationOfNewMassAlertNotification;

@interface TSJavelinPushNotificationManager : NSObject

+ (void)analyzeNotification:(NSDictionary *)userInfo completion:(void (^)(BOOL matchFound, NSString *message))completion;

@end
