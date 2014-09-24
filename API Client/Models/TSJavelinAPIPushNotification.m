//
//  TSJavelinAPIPushNotification.m
//  TapShield
//
//  Created by Adam Share on 9/24/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSJavelinAPIPushNotification.h"

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
                            _alertType = alert[@"alert_type"];
                        }
                        if ([alert nonNullObjectForKey:@"alert_id"]) {
                            _alertID = alert[@"alert_id"];
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
