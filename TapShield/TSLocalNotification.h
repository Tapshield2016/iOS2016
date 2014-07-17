//
//  TSLocalNotification.h
//  TapShield
//
//  Created by Adam Share on 5/10/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSLocalNotification : NSObject

+ (void)presentLocalNotification:(NSString *)message;
+ (void)presentLocalNotification:(NSString *)message  fireDate:(NSDate *)date;
+ (void)presentLocalNotification:(NSString *)message  openDestination:(NSString *)storyboardID;
+ (void)presentLocalNotification:(NSString *)message  openDestination:(NSString *)storyboardID alertAction:(NSString *)action;
+ (void)say:(NSString *)string;

@end
