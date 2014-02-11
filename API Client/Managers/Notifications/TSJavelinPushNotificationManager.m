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

@implementation TSJavelinPushNotificationManager

+ (void)analyzeNotification:(NSDictionary *)userInfo completion:(void (^)(BOOL matchFound, NSString *message))completion {
    NSDictionary *alert;
    NSString *alertType;
    NSString *alertID;
    NSString *alertBody;

    if ([userInfo objectForKey:@"aps"]) {
        
        if (![[userInfo objectForKey:@"aps"] isKindOfClass:[NSDictionary class]]) {
            return;
        }
        
        if ([userInfo[@"aps"] objectForKey:@"alert"]) {
            
            if (![[userInfo[@"aps"] objectForKey:@"alert"] isKindOfClass:[NSDictionary class]]) {
                return;
            }
            alert = userInfo[@"aps"][@"alert"];
            if ([alert objectForKey:@"alert_type"]) {
                alertType = alert[@"alert_type"];
            }
            if ([alert objectForKey:@"alert_id"]) {
                alertID = alert[@"alert_id"];
            }
            if ([alert objectForKey:@"body"]) {
                alertBody = alert[@"body"];
            }

            if (alertType && alertID) {
                if ([alertType isEqualToString:@"alert-received"]) {
                    NSLog(@"Our alert was acknowledged! - %@", alertType);
                    NSLog(@"Alert ID: %@", alertID);
                    if (completion) {
                        completion(YES, alertBody);
                    }
                    [[TSJavelinAPIClient sharedClient] alertReceiptReceivedForAlertWithURL:alertID];
                }
                else if ([alertType isEqualToString:@"chat-message-available"]) {
                    NSLog(@"New chat message available! - %@", alertType);
                    NSLog(@"Alert ID: %@", alertID);
                    if (completion) {
                        completion(YES, alertBody);
                    }
                    [[TSJavelinAPIClient sharedClient] receivedNotificationOfNewChatMessageAvailableForActiveAlert:alert];
                    [[NSNotificationCenter defaultCenter] postNotificationName: TSJavelinPushNotificationManagerDidReceiveNotificationOfNewChatMessageNotification
                                                                        object:alertBody];
                }
                else if ([alertType isEqualToString:@"mass-alert"]) {
                    NSLog(@"New mass alert! - %@", alertType);
                    NSLog(@"Alert ID: %@", alertID);
                    if (completion) {
                        completion(YES, alertBody);
                    }
                    [[TSJavelinAPIClient sharedClient] receivedNotificationOfNewMassAlert:alert];
                    [[NSNotificationCenter defaultCenter] postNotificationName: TSJavelinPushNotificationManagerDidReceiveNotificationOfNewMassAlertNotification
                                                                        object:alertBody];
                }
                else {
                    if (completion) {
                        completion(NO, alertBody);
                    }
                }
                
                return;
            }
        }
    }

    if (completion) {
        completion(NO, nil);
    }
}

@end
