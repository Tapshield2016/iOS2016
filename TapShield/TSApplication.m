//
//  TSApplication.m
//  TapShield
//
//  Created by Adam Share on 9/4/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSApplication.h"

@implementation TSApplication

- (BOOL)openURL:(NSURL*)url {
    
    if ([[url absoluteString] hasPrefix:@"googlechrome-x-callback:"]) {
        return NO;
        
    } else if ([[url absoluteString] hasPrefix:@"https://accounts.google.com/o/oauth2/auth"]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:ApplicationOpenGoogleAuthNotification object:url];
        return NO;
    }
    
    return [super openURL:url];
}


@end
