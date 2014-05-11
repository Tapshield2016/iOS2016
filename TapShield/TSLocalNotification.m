//
//  TSLocalNotification.m
//  TapShield
//
//  Created by Adam Share on 5/10/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSLocalNotification.h"
#import <AVFoundation/AVFoundation.h>

@implementation TSLocalNotification

+ (UILocalNotification *)localNotificationWithMessage:(NSString *)message date:(NSDate *)date {
    
    UILocalNotification *note = [[UILocalNotification alloc] init];
    note.alertBody = message;
    note.soundName = UILocalNotificationDefaultSoundName;
    note.fireDate = date;
    return note;
}


+ (void)presentLocalNotification:(NSString *)message {
    
    AudioServicesPlaySystemSound( kSystemSoundID_Vibrate );
    
    UILocalNotification *localNote = [TSLocalNotification localNotificationWithMessage:message date:nil];
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNote];
}

+ (void)presentLocalNotification:(NSString *)message  openDestination:(NSString *)storyboardID {
    
    AudioServicesPlaySystemSound( kSystemSoundID_Vibrate );
    
    UILocalNotification *localNote = [TSLocalNotification localNotificationWithMessage:message date:nil];
    localNote.userInfo = @{@"destination": storyboardID};
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNote];
}

+ (void)presentLocalNotification:(NSString *)message  fireDate:(NSDate *)date {
    
    if ([date timeIntervalSinceNow] <= 0) {
        return;
    }
    
    UILocalNotification *localNote = [TSLocalNotification localNotificationWithMessage:message date:date];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNote];
}




@end
