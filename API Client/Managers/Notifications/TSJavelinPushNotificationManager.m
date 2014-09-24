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

NSString * const TSJavelinPushNotificationTypeCrimeReport = @"crime-report";
NSString * const TSJavelinPushNotificationTypeMassAlert = @"mass-alert";
NSString * const TSJavelinPushNotificationTypeChatMessage = @"chat-message-available";
NSString * const TSJavelinPushNotificationTypeAlertReceived = @"alert-received";


@implementation TSJavelinPushNotificationManager

+ (void)analyzeNotification:(NSDictionary *)userInfo completion:(void (^)(BOOL matchFound, TSJavelinAPIPushNotification *notification))completion {
    
    TSJavelinAPIPushNotification *notification = [[TSJavelinAPIPushNotification alloc] initWithAttributes:userInfo];
    
    if (notification.alertType && notification.alertID) {
        if ([notification.alertType isEqualToString:@"alert-received"]) {
            NSLog(@"Our alert was acknowledged! - %@", notification.alertType);
            NSLog(@"Alert ID: %@", notification.alertID);
            if (completion) {
                completion(YES, notification);
            }
            [[TSJavelinAPIClient sharedClient] alertReceiptReceivedForAlertWithURL:notification.alertID];
        }
        else if ([notification.alertType isEqualToString:@"chat-message-available"]) {
            NSLog(@"New chat message available! - %@", notification.alertType);
            NSLog(@"Alert ID: %@", notification.alertID);
            if (completion) {
                completion(YES, notification);
            }
            [[TSJavelinAPIClient sharedClient] receivedNotificationOfNewChatMessageAvailableForActiveAlert:notification];
            [[NSNotificationCenter defaultCenter] postNotificationName: TSJavelinPushNotificationManagerDidReceiveNotificationOfNewChatMessageNotification
                                                                object:notification];
        }
        else if ([notification.alertType isEqualToString:@"mass-alert"]) {
            NSLog(@"New mass alert! - %@", notification.alertType);
            NSLog(@"Alert ID: %@", notification.alertID);
            if (completion) {
                completion(YES, notification);
            }
            [[TSJavelinAPIClient sharedClient] receivedNotificationOfNewMassAlert:notification];
            [[NSNotificationCenter defaultCenter] postNotificationName: TSJavelinPushNotificationManagerDidReceiveNotificationOfNewMassAlertNotification
                                                                object:notification];
        }
        else if ([notification.alertType isEqualToString:@"crime-report"]) {
            NSLog(@"New crime report! - %@", notification.alertType);
            NSLog(@"Alert ID: %@", notification.alertID);
            if (completion) {
                completion(YES, notification);
            }
            [[TSJavelinAPIClient sharedClient] receivedNotificationOfNewMassAlert:notification];
            [[NSNotificationCenter defaultCenter] postNotificationName: TSJavelinPushNotificationManagerDidReceiveNotificationOfNewMassAlertNotification
                                                                object:notification];
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

@end
