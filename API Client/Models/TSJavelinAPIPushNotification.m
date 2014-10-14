//
//  TSJavelinAPIPushNotification.m
//  TapShield
//
//  Created by Adam Share on 9/24/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIPushNotification.h"
#import "TSJavelinAPIClient.h"
#import "TSJavelinPushNotificationManager.h"

@implementation TSJavelinAPIPushNotification

- (instancetype)initWithAttributes:(NSDictionary *)userInfo
{
    self = [super initWithAttributes:userInfo];
    if (self) {
        
        if ([userInfo objectForKey:@"aps"]) {
            
            if ([[userInfo objectForKey:@"aps"] isKindOfClass:[NSDictionary class]]) {
                
                if ([userInfo[@"aps"] objectForKey:@"alert"]) {
                    
                    if ([[userInfo[@"aps"] objectForKey:@"alert"] isKindOfClass:[NSDictionary class]]) {
                        
                        NSDictionary *alert = userInfo[@"aps"][@"alert"];
                        
                        if ([alert nonNullObjectForKey:@"alert_type"]) {
                            _alertType = [alert nonNullObjectForKey:@"alert_type"];
                            NSArray *types = @[TSJavelinPushNotificationTypeCrimeReport, TSJavelinPushNotificationTypeMassAlert,TSJavelinPushNotificationTypeChatMessage,TSJavelinPushNotificationTypeAlertReceived,TSJavelinPushNotificationTypeAlertCompletion];
                            for (NSString *constType in types) {
                                if ([_alertType isEqualToString:constType]) {
                                    _alertType = constType;
                                }
                            }
                        }
                        if ([alert nonNullObjectForKey:@"alert_id"]) {
                            _alertID = alert[@"alert_id"];
                            
                            _alertUrl = _alertID;//[NSString stringWithFormat:@"%@://%@%@", [[TSJavelinAPIClient sharedClient] baseURL].scheme, [[TSJavelinAPIClient sharedClient] baseURL].host, _alertID];
                        }
                        if ([alert nonNullObjectForKey:@"body"]) {
                            _alertBody = alert[@"body"];
                        }
                    }
                }}
        }
    }
    return self;
}

@end
