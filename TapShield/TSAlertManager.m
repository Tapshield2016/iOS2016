//
//  TSAlertManager.m
//  TapShield
//
//  Created by Adam Share on 5/8/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSAlertManager.h"
#import "TSLocationController.h"
#import "TSVirtualEntourageManager.h"
#import <AVFoundation/AVFoundation.h>
#import "TSLocalNotification.h"

NSString * const kAlertSend = @"Send alert";
NSString * const kAlertSending = @"Sending alert";
NSString * const kAlertSent = @"Alert was sent";
NSString * const kAlertReceived = @"The authorities have been notified";
NSString * const kAlertOutsideGeofence = @"Outside boundaries please call";
NSString * const kAlertNoConnection = @"No Network Connection";

@interface TSAlertManager ()

@property (strong, nonatomic) UIAlertView *noConnectionAlertView;
@property (strong, nonatomic) NSString *previousStatus;

@end

@implementation TSAlertManager

static TSAlertManager *_sharedAlertManagerInstance = nil;
static dispatch_once_t predicate;

+ (instancetype)sharedManager {
    
    if (_sharedAlertManagerInstance == nil) {
        dispatch_once(&predicate, ^{
            _sharedAlertManagerInstance = [[self alloc] init];
        });
    }
    return _sharedAlertManagerInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.callInProgress = NO;
        self.status = kAlertSend;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(alertRecieved:)
                                                     name:TSJavelinAlertManagerDidRecieveActiveAlertNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didFindConnection)
                                                     name:TSAppDelegateDidFindConnection
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didLoseConnection)
                                                     name:TSAppDelegateDidLoseConnection
                                                   object:nil];
    }
    
    return self;
}

- (void)alertRecieved:(NSNotification *)notification {
    
    if ([_alertDelegate respondsToSelector:@selector(alertStatusChanged:)]) {
        [_alertDelegate alertStatusChanged:kAlertReceived];
    }
}

#pragma mark - Countdown To Alert

- (void)startAlertCountdown:(int)seconds type:(NSString *)type {
    
    [self stopAlertCountdown];
    
    if (!type) {
        type = @"E";
    }
    
    _type = type;
    _endDate = [NSDate dateWithTimeInterval:seconds sinceDate:[NSDate date]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
        _countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                           target:self
                                                         selector:@selector(countdown:)
                                                         userInfo:nil
                                                          repeats:YES];
    });
}

- (void)stopAlertCountdown {
    
    [_countdownTimer invalidate];
    _countdownTimer = nil;
}

- (void)countdown:(NSTimer *)timer {
    
    AudioServicesPlaySystemSound( kSystemSoundID_Vibrate );
    
    if ([_endDate timeIntervalSinceNow] <= 0) {
        [self sendAlert:nil];
    }
}

- (void)sendAlert:(NSString *)type {
    
    if (!type) {
        type = _type;
    }
    
    [self stopAlertCountdown];
    
    [[TSVirtualEntourageManager sharedManager] failedToArriveAtDestination];
    
    _status = kAlertSending;
    if ([_alertDelegate respondsToSelector:@selector(alertStatusChanged:)]) {
        [_alertDelegate alertStatusChanged:kAlertSending];
    }
    
    if (![(TSAppDelegate *)[UIApplication sharedApplication].delegate isConnected]) {
        
        [self didLoseConnection];
        
        NSString *number = [[TSJavelinAPIClient sharedClient].authenticationManager loggedInUser].agency.dispatcherSecondaryPhoneNumber;
        if (!number) {
            number = kEmergencyNumber;
        }
        NSString *callButtonTitle = [NSString stringWithFormat:@"Call %@", number];
        _noConnectionAlertView = [[UIAlertView alloc] initWithTitle:@"No Network Data Connection"
                                                               message:nil
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                     otherButtonTitles:callButtonTitle, nil];
        [_noConnectionAlertView show];
        
        [TSLocalNotification presentLocalNotification:[NSString stringWithFormat:@"WARNING: No Network Data Connection. Call %@.", number] openDestination:kAlertOutsideGeofence alertAction:@"Call"];
    }
    
    [[TSJavelinAPIClient sharedClient] sendEmergencyAlertWithAlertType:type location:[TSLocationController sharedLocationController].location completion:^(BOOL sent, BOOL inside) {
        if (sent) {
            _status = kAlertSent;
            if ([_alertDelegate respondsToSelector:@selector(alertStatusChanged:)]) {
                [_alertDelegate alertStatusChanged:_status];
            }
        }
        else {
            NSLog(@"Alert did not send");
        }
        
        if (inside) {
            if ([[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].agency.launchCallToDispatcherOnAlert  &&
                ![type isEqualToString:@"C"]) {
                [self startTwilioCall];
            }
            
        }
        else {
            [self alertSentOutsideGeofence];
        }
        
    }];
}

- (void)alertSentOutsideGeofence {
    
    NSString *number = [[TSJavelinAPIClient sharedClient].authenticationManager loggedInUser].agency.dispatcherSecondaryPhoneNumber;
    if (!number) {
        number = kEmergencyNumber;
    }
    [TSLocalNotification presentLocalNotification:[NSString stringWithFormat:@"WARNING: You are located outside of your agency's boundaries. Call %@.", number] openDestination:kAlertOutsideGeofence alertAction:@"Call"];
    
    NSLog(@"Outside geofence");
    _status = kAlertOutsideGeofence;
    if ([_alertDelegate respondsToSelector:@selector(alertStatusChanged:)]) {
        [_alertDelegate alertStatusChanged:_status];
    }
    
    [[TSAlertManager sharedManager] callSecondary];
}

- (void)callPrimary {
    
    NSString *rawPhoneNum = [[TSJavelinAPIClient sharedClient].authenticationManager loggedInUser].agency.dispatcherPhoneNumber;
    if (rawPhoneNum) {
        [self voiceCall:rawPhoneNum];
    }
    else {
        [self callSecondary];
    }
}

- (void)callSecondary {
    
    NSString *rawPhoneNum = [[TSJavelinAPIClient sharedClient].authenticationManager loggedInUser].agency.dispatcherSecondaryPhoneNumber;
    if (!rawPhoneNum) {
#warning 911
        rawPhoneNum = kEmergencyNumber;
    }
    
    [self voiceCall:rawPhoneNum];
}

- (void)voiceCall:(NSString *)number {
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]]) {
        
        
        NSString *phoneNumber = [@"tel://" stringByAppendingString:number];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
        });
    }
    else {
        UIAlertView *phoneServiceUnavailableAlert = [[UIAlertView alloc] initWithTitle:nil
                                                                               message:@"This device is not setup to make phone calls"
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [phoneServiceUnavailableAlert show];
        });
    }
}

- (void)disarmAlert {
    
    [self stopAlertCountdown];
    [self endTwilioCall];
    _type = nil;
    _endDate = nil;
    _status = kAlertSend;
}


#pragma mark - Twilio Setup

- (BOOL)capabilityTokenValid
{
	//Check TCDevice's capability token to see if it is still valid
	BOOL isValid = NO;
	NSNumber* expirationTimeObject = [_twilioDevice.capabilities objectForKey:@"expiration"];
	long long expirationTimeValue = [expirationTimeObject longLongValue];
	long long currentTimeValue = (long long)[[NSDate date] timeIntervalSince1970];
    
	if ((expirationTimeValue - currentTimeValue) > 0) {
        isValid = YES;
    }
	
	return isValid;
}

- (void)getTwilioCallToken:(void(^)(NSString *callToken))completion {
    
    if (_callToken) {
        if ([self capabilityTokenValid]) {
            if (completion) {
                completion(_callToken);
                return;
            }
        }
    }
    
    [[TSJavelinAPIClient sharedClient] getTwilioCallToken:completion];
}

- (void)startTwilioCall {
    
    if ([[TSAlertManager sharedManager].status isEqualToString:kAlertOutsideGeofence]) {
        [self callSecondary];
        return;
    }
    
    
    if ([[TSAlertManager sharedManager].status isEqualToString:kAlertNoConnection]) {
        if ([_previousStatus isEqualToString:kAlertSent] || [_previousStatus isEqualToString:kAlertReceived]) {
            [self callPrimary];
        }
        else if ([_previousStatus isEqualToString:kAlertSending]) {
            [self callSecondary];
        }
        return;
    }
    
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (!granted) {
            // Microphone disabled code
            UIAlertView *microphoneAccessDeniedAlert = [[UIAlertView alloc] initWithTitle:@"Microphone Access Was Denied."
                                                                                  message:@"You will not be heard during VOIP phone services.\n\nPlease enable Microphone access for this app in Settings / Privacy / Microphone"
                                                                                 delegate:nil
                                                                        cancelButtonTitle:@"OK"
                                                                        otherButtonTitles:nil];
            [microphoneAccessDeniedAlert show];
        }
        [self connectToDispatcher];
    }];
}

- (void)connectToDispatcher {
    
    if ([_alertDelegate respondsToSelector:@selector(startingPhoneCall)]) {
        [_alertDelegate startingPhoneCall];
    }
    
    _callInProgress = YES;
    
    [self voipDisconnect];
//    _redialButton.enabled = NO;
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    
//    [self updatePhoneNumberWithMessage:kCallConnecting];
    
    [self getTwilioCallToken:^(NSString *callToken) {
        
        _callToken = callToken;
        _twilioDevice = [[TCDevice alloc] initWithCapabilityToken:callToken delegate:self];
        _twilioDevice.outgoingSoundEnabled = YES;
        _twilioDevice.incomingSoundEnabled = YES;
        _twilioDevice.disconnectSoundEnabled = YES;
        
        
        NSString *phoneNumber = [[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].agency.dispatcherPhoneNumber;
        
        if (phoneNumber) {
            _twilioConnection = [_twilioDevice connect:@{@"To": phoneNumber} delegate:self];
        }
    }];
}

#pragma mark - Actions

- (void)endTwilioCall {
    [self voipDisconnect];
}

- (void)voipDisconnect {
    [_twilioConnection disconnect];
    [_twilioDevice disconnectAll];
}

- (BOOL)updateAudioRoute:(BOOL)enabled {
    
    NSError *error;
	if (enabled) {
        return enabled = [[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker
                                                                            error:&error];
        if (!enabled) {
            NSLog(@"AVAudioSession error overrideOutputAudioPort:%@",error);
        }
	}
	else {
        return enabled = ![[AVAudioSession sharedInstance] overrideOutputAudioPort:AVAudioSessionPortOverrideNone
                                                                             error:&error];
        if (enabled) {
            NSLog(@"AVAudioSession error overrideOutputAudioPort:%@",error);
        }
	}
}


#pragma mark - Twilio Connection Delegate

- (void)connectionDidStartConnecting:(TCConnection *)connection {
    
    if ([_callDelegate respondsToSelector:@selector(connectionDidStartConnecting:)]) {
        [_callDelegate connectionDidStartConnecting:connection];
    }
}

- (void)connectionDidConnect:(TCConnection *)connection {
    
    _callStartTime = [NSDate date];
    
    if ([_callDelegate respondsToSelector:@selector(connectionDidConnect:)]) {
        [_callDelegate connectionDidConnect:connection];
    }
}


- (void)connectionDidDisconnect:(TCConnection *)connection {
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    
    _callStartTime = nil;
    self.callInProgress = NO;
    
    if ([_callDelegate respondsToSelector:@selector(connectionDidDisconnect:)]) {
        [_callDelegate connectionDidDisconnect:connection];
    }
}

- (void)connection:(TCConnection *)connection didFailWithError:(NSError *)error {
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    
    _callStartTime = nil;
    self.callInProgress = NO;
    
    if ([_callDelegate respondsToSelector:@selector(connection:didFailWithError:)]) {
        [_callDelegate connection:connection didFailWithError:error];
    }
}

#pragma mark - Twilio Device Delegate

- (void)device:(TCDevice *)device didReceiveIncomingConnection:(TCConnection *)connection {
    
}

- (void)device:(TCDevice *)device didReceivePresenceUpdate:(TCPresenceEvent *)presenceEvent {
    
}

- (void)device:(TCDevice *)device didStopListeningForIncomingConnections:(NSError *)error {
    
}

- (void)deviceDidStartListeningForIncomingConnections:(TCDevice *)device {
    
}


#pragma mark - Alert View Delegate 

- (void)didFindConnection {
    
    [_noConnectionAlertView dismissWithClickedButtonIndex:-1 animated:YES];
    
    if ([_previousStatus isEqualToString:kAlertSending]) {
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
    
    _status = _previousStatus;
    if ([_alertDelegate respondsToSelector:@selector(alertStatusChanged:)]) {
        [_alertDelegate alertStatusChanged:_status];
    }
}

- (void)didLoseConnection {
    
    _previousStatus = _status;
    
    _status = kAlertNoConnection;
    if ([_alertDelegate respondsToSelector:@selector(alertStatusChanged:)]) {
        [_alertDelegate alertStatusChanged:_status];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (alertView == _noConnectionAlertView) {
        if (buttonIndex == 1) {
            [self callSecondary];
        }
    }
}

@end
