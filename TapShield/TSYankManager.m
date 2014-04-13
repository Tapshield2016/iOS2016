//
//  TSYankManager.m
//  TapShield
//
//  Created by Adam Share on 4/13/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSYankManager.h"

@implementation TSYankManager

static TSYankManager *_sharedYankManagerInstance = nil;
static dispatch_once_t predicate;

+ (instancetype)sharedLocationController {
    
    if (_sharedYankManagerInstance == nil) {
        dispatch_once(&predicate, ^{
            _sharedYankManagerInstance = [[self alloc] init];
        });
    }
    return _sharedYankManagerInstance;
}

#pragma mark - Yank

void audioRouteChangeListenerCallback (void *inUserData, AudioSessionPropertyID inPropertyID, UInt32 inPropertyValueSize, const void *inPropertyValue )  {
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:YANK_ENABLED])  {
        // ensure that this callback was invoked for a route change
        if (inPropertyID != kAudioSessionProperty_AudioRouteChange) {
            return;
        }
        // Determines the reason for the route change, to ensure that it is not
        //      because of a category change.
        CFDictionaryRef routeChangeDictionary = (CFDictionaryRef)inPropertyValue;
        CFNumberRef routeChangeReasonRef = (CFNumberRef)CFDictionaryGetValue (routeChangeDictionary, CFSTR (kAudioSession_AudioRouteChangeKey_Reason) );
        SInt32 routeChangeReason;
        CFNumberGetValue (routeChangeReasonRef, kCFNumberSInt32Type, &routeChangeReason);
        
        if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) {
            // Headset Taken out
            if ([[NSUserDefaults standardUserDefaults] boolForKey:YANK_ENABLED])
                [[NSNotificationCenter defaultCenter] postNotificationName:FIRE_YANK_ALERT object:nil];
        }
        else if (routeChangeReason == kAudioSessionRouteChangeReason_NewDeviceAvailable) {
            // Headset Plugged in
            [[NSNotificationCenter defaultCenter] postNotificationName:HEADSET_PLUGGED_IN object:nil];
        }
    }
}



- (BOOL)isHeadsetPluggedIn
{
    // Get array of current audio outputs (there should only be one)
    NSArray *outputs = [[AVAudioSession sharedInstance] currentRoute].outputs;
    NSString *portName = [[outputs objectAtIndex:0] portName];
    
    if ([portName isEqualToString:@"Headphones"]) {
        return YES;
    }
    
    return NO;
}


@end
