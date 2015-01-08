//
//  TSLocalNotification.m
//  TapShield
//
//  Created by Adam Share on 5/10/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSLocalNotification.h"
#import "TSAppDelegate.h"
#import "TSEntourageSessionManager.h"

@implementation TSLocalNotification

static TSLocalNotification *_sharedInstance = nil;
static dispatch_once_t predicate;

+ (instancetype)sharedManager {
    
    if (_sharedInstance == nil) {
        dispatch_once(&predicate, ^{
            _sharedInstance = [[self alloc] init];
        });
    }
    return _sharedInstance;
}

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


+ (void)presentLocalNotification:(NSString *)message  openDestination:(NSString *)storyboardID alertAction:(NSString *)action {
    
    AudioServicesPlaySystemSound( kSystemSoundID_Vibrate );
    
    UILocalNotification *localNote = [TSLocalNotification localNotificationWithMessage:message date:nil];
    localNote.userInfo = @{@"destination": storyboardID};
    localNote.alertAction = action;
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNote];
}


#pragma mark - Text To Speech 

+ (void)say:(NSString *)string {
    
    AudioServicesPlaySystemSound( kSystemSoundID_Vibrate );
    
    NSError *error = NULL;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback
             withOptions:AVAudioSessionCategoryOptionDuckOthers
                   error:&error];
    [session setActive:YES error:&error];
    if (error) {
        // Do some error handling
    }
    
    AVSpeechSynthesizer *synthesizer = [TSLocalNotification speechSynth];
    AVSpeechUtterance *utterance = [AVSpeechUtterance speechUtteranceWithString:string];
    [utterance setRate:AVSpeechUtteranceDefaultSpeechRate/4];
    
    if (synthesizer.isSpeaking) {
        [synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    }
    [synthesizer speakUtterance:utterance];
}

+ (AVSpeechSynthesizer *)speechSynth {
    
    if (![TSLocalNotification sharedManager].synthesizer) {
        [TSLocalNotification sharedManager].synthesizer = [[AVSpeechSynthesizer alloc] init];
        [TSLocalNotification sharedManager].synthesizer.delegate = [TSLocalNotification sharedManager];
    }
    
    return [TSLocalNotification sharedManager].synthesizer;
}

#pragma mark - Speech Delegate

- (void)speechSynthesizer:(AVSpeechSynthesizer *)synthesizer didFinishSpeechUtterance:(AVSpeechUtterance *)utterance
{
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}

@end
