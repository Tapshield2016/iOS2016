//
//  TSAlertManager.m
//  TapShield
//
//  Created by Adam Share on 5/8/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSAlertManager.h"
#import "TSLocationController.h"
#import "TSEntourageSessionManager.h"
#import <AVFoundation/AVFoundation.h>
#import "TSLocalNotification.h"
#import "TSPageViewController.h"
#import "TSUtilities.h"

NSString * const kAlertType911Call = @"N";
NSString * const kAlertTypeAlertCall = @"E";
NSString * const kAlertTypeEntourage = @"T";
NSString * const kAlertTypeYank = @"Y";
NSString * const kAlertTypeChat = @"C";

NSString * const kAlertWindowAnimationTypeDown = @"Down";
NSString * const kAlertWindowAnimationTypeZoomIn = @"ZoomIn";
NSString * const kAlertWindowAnimationTypeZoomOut = @"ZoomOut";

NSString * const kAlertSend = @"Send alert";
NSString * const kAlertSending = @"Sending alert";
NSString * const kAlertSent = @"Alert was sent";
NSString * const kAlertReceived = @"The authorities have been notified";
NSString * const kAlertOutsideGeofence = @"Outside boundaries please call";
NSString * const kAlertClosedDispatchCenter = @"Dispatch center closed please call";
NSString * const kAlertNoConnection = @"No Network Connection";

#define kNoConnectionNotification @"WARNING: No Network Data Connection. Call %@."
#define kOutsideNotification @"WARNING: You are located outside of your organization's boundaries. Call %@."
#define kClosedNotification @"WARNING: Your organization's dispatch center is closed. Call %@."

@interface TSAlertManager ()

@property (strong, nonatomic) UIAlertController *noConnectionAlertController;
@property (strong, nonatomic) NSString *previousStatus;
@property (assign, nonatomic) BOOL shouldStartTimer;
@property (assign, nonatomic) BOOL shouldStopTimer;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) TSPageViewController *pageviewController;

@property (strong, nonatomic) NSTimer *emergencyCallTimer;
@property (assign, nonatomic) BOOL emergencyCallInProgress;
@property (strong, nonatomic) NSDate *emergencyCallStartTime;

@property (strong, nonatomic) NSSet *currentCalls;
@property (strong, nonatomic) CTCall *emergencyCall;
@property (assign, nonatomic) BOOL shouldMakeEmergencyCall;

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
        _callInProgress = NO;
        _shouldStartTimer = YES;
        _shouldStopTimer = NO;
        _isAlertInProgress = NO;
        _status = kAlertSend;
        _isPresented = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didFindConnection:)
                                                     name:TSAppDelegateDidFindConnection
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didLoseConnection:)
                                                     name:TSAppDelegateDidLoseConnection
                                                   object:nil];
        
        [TSJavelinAlertManager sharedManager].delegate = self;
    }
    
    return self;
}

#pragma mark - TSJavelinAlertManagerDelegate

- (void)dispatcherDidCompleteAlert:(TSJavelinAPIAlert *)alert {
    
    [self disarmAlert];
}

- (void)alertManagerDidNotFindAlert:(TSJavelinAPIAlert *)alert {
    
    if (_type != kAlertType911Call) {
        [self askIfEmergency];
    }
}

- (void)askIfEmergency {
    
    NSString *number = [[TSJavelinAPIClient sharedClient].authenticationManager loggedInUser].agency.dispatcherSecondaryPhoneNumber;
    if (!number) {
        number = kEmergencyNumber;
    }
    NSString *callButtonTitle = [NSString stringWithFormat:@"Call %@", number];
    
    _noConnectionAlertController = [UIAlertController alertControllerWithTitle:@"No Response"
                                                                       message:@"TapShield has not received a response. Is this an Emergency?"
                                                                preferredStyle:UIAlertControllerStyleAlert];
    [_noConnectionAlertController addAction:[UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil]];
    [_noConnectionAlertController addAction:[UIAlertAction actionWithTitle:callButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self callEmergencyNumber];
    }]];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.window.rootViewController presentViewController:_noConnectionAlertController animated:YES completion:nil];
    }];
    
    [TSLocalNotification presentLocalNotification:[NSString stringWithFormat:kNoConnectionNotification, number] openDestination:kAlertOutsideGeofence alertAction:@"Call"];
}

- (void)startEmergencyNumberAlert {
    
    [self sendEmergencyTypeAlertWithTimeOut];
    [self showAlertWindowWithoutCountdown];
}

- (void)startAgencyDispathcerCallAlert {
    
    [self sendAlertType:kAlertTypeAlertCall];
    [self showAlertWindowWithoutCountdown];
}

- (void)startChatAlert {
    
    [self sendChatAlert];
}

- (void)startYankAlertCountdown {
    
    [self showAlertWindowAndStartCountdownWithType:kAlertTypeYank];
}

- (void)startEntourageAlertCountdown {
    
    [self showAlertWindowAndStartCountdownWithType:kAlertTypeEntourage];
}

- (void)alertManagerDidReceiveAlert:(TSJavelinAPIAlert *)alert {
    
    if ([_alertDelegate respondsToSelector:@selector(alertStatusChanged:)]) {
        [_alertDelegate alertStatusChanged:kAlertReceived];
    }
}

- (void)showAlertWindowAndStartCountdownWithType:(NSString *)type {
    
    if (_isPresented){
        return;
    }
    _isPresented = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[TSAlertManager sharedManager] startAlertCountdown:10 type:type];
        
        _pageviewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TSPageViewController class])];
        [self showWindowWithRootViewController:_pageviewController animated:YES animationType:kAlertWindowAnimationTypeZoomIn completion:nil];
    });
}

- (void)showAlertWindowForChat {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        _pageviewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TSPageViewController class])];
        _pageviewController.isChatPresentation = YES;
        [self showWindowWithRootViewController:_pageviewController animated:YES animationType:kAlertWindowAnimationTypeDown completion:nil];
    });
}

- (void)showAlertWindowWithoutCountdown {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        _pageviewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TSPageViewController class])];
        _pageviewController.isAlertPresentation = YES;
        [self showWindowWithRootViewController:_pageviewController animated:YES animationType:kAlertWindowAnimationTypeZoomOut completion:nil];
    });
}

#pragma mark - Countdown To Alert

- (void)startAlertCountdown:(int)seconds type:(NSString *)type {
    
    if (!_shouldStartTimer) {
        return;
    }
    _shouldStartTimer = NO;
    _shouldStopTimer = NO;
    [[TSLocationController sharedLocationController] bestAccuracyForAlert];
    
    [self stopAlertCountdown];
    
    if (!type) {
        type = kAlertTypeAlertCall;
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
    
    if (_shouldStopTimer) {
        return;
    }
    
    AudioServicesPlaySystemSound( kSystemSoundID_Vibrate );
    
    if ([_endDate timeIntervalSinceNow] <= 0) {
        [self sendAlertType:nil];
    }
}

- (void)sendAlertType:(NSString *)type {
    
    if (!type) {
        type = _type;
    }
    else {
        _type = type;
    }
    
    _isAlertInProgress = YES;
    
    [self stopAlertCountdown];
    
    [[TSEntourageSessionManager sharedManager] failedToArriveAtDestination];
    
    _status = kAlertSending;
    if ([_alertDelegate respondsToSelector:@selector(alertStatusChanged:)]) {
        [_alertDelegate alertStatusChanged:kAlertSending];
    }
    
    if (![(TSAppDelegate *)[UIApplication sharedApplication].delegate isConnected]) {
        
        [self didLoseConnection:nil];
        
        NSString *number = [[TSJavelinAPIClient sharedClient].authenticationManager loggedInUser].agency.dispatcherSecondaryPhoneNumber;
        if (!number) {
            number = kEmergencyNumber;
        }
        NSString *callButtonTitle = [NSString stringWithFormat:@"Call %@", number];
        
        _noConnectionAlertController = [UIAlertController alertControllerWithTitle:@"No Network Data Connection"
                                                                           message:nil
                                                                    preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:callButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self callEmergencyNumber];
        }];
        [_noConnectionAlertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [_noConnectionAlertController addAction:action];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.window.rootViewController presentViewController:_noConnectionAlertController animated:YES completion:nil];
        }];
        
        [TSLocalNotification presentLocalNotification:[NSString stringWithFormat:kNoConnectionNotification, number] openDestination:kAlertOutsideGeofence alertAction:@"Call"];
    }
    
    [[TSJavelinAPIClient sharedClient] sendQueuedAlertWithAlertType:type location:[TSLocationController sharedLocationController].location completion:^(BOOL sent, BOOL inside) {
        
        if (!_isAlertInProgress) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self silentDisarmAlert];
            }];
            return;
        }
        
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
                ![type isEqualToString:kAlertTypeChat]) {
                [self startTwilioCall];
            }
            
        }
        else if (![type isEqualToString:kAlertTypeChat]) {
            [self alertSentOutsideGeofence];
        }
        
    }];
}

- (void)sendChatAlert {
    
    _type = kAlertTypeChat;
    
    _isAlertInProgress = YES;
    
    _status = kAlertSending;
    if ([_alertDelegate respondsToSelector:@selector(alertStatusChanged:)]) {
        [_alertDelegate alertStatusChanged:kAlertSending];
    }
    
    
    [[TSJavelinAPIClient sharedClient] sendDirectRestAPIAlertWithAlertType:_type location:[TSLocationController sharedLocationController].location completion:^(TSJavelinAPIAlert *activeAlert, BOOL inside) {
        
        if (!_isAlertInProgress) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self silentDisarmAlert];
            }];
            return;
        }
        
        if (activeAlert) {
            _status = kAlertSent;
            if ([_alertDelegate respondsToSelector:@selector(alertStatusChanged:)]) {
                [_alertDelegate alertStatusChanged:_status];
            }
        }
        else {
            NSLog(@"Alert did not send");
        }
    }];

    
}

- (void)sendEmergencyTypeAlertWithTimeOut {
    
    _isAlertInProgress = YES;
    
    [self stopAlertCountdown];
    
    [[TSEntourageSessionManager sharedManager] failedToArriveAtDestination];
    
    _type = kAlertType911Call;
    
    _status = kAlertSending;
    if ([_alertDelegate respondsToSelector:@selector(alertStatusChanged:)]) {
        [_alertDelegate alertStatusChanged:kAlertSending];
    }
    
    [self startEmergencyAlertTimerTimeOut];
    
    [[TSJavelinAPIClient sharedClient] sendQueuedAlertWithAlertType:kAlertType911Call location:[TSLocationController sharedLocationController].location completion:^(BOOL sent, BOOL inside) {
        
        if (!_isAlertInProgress) {
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self silentDisarmAlert];
            }];
            return;
        }
        
        if (sent) {
            _status = kAlertSent;
            if ([_alertDelegate respondsToSelector:@selector(alertStatusChanged:)]) {
                [_alertDelegate alertStatusChanged:_status];
            }
        }
        else {
            NSLog(@"Alert did not send");
        }
        
        if (!inside) {
            _status = kAlertOutsideGeofence;
            if ([_alertDelegate respondsToSelector:@selector(alertStatusChanged:)]) {
                [_alertDelegate alertStatusChanged:_status];
            }
        }
        
        [[TSAlertManager sharedManager] callEmergencyNumber];
    }];
}

- (void)startEmergencyAlertTimerTimeOut {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        _emergencyCallTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                      target:self
                                                    selector:@selector(callEmergencyNumber)
                                                    userInfo:nil
                                                     repeats:NO];
    }];
}

- (void)alertSentOutsideGeofence {
    
    NSString *number = [[TSJavelinAPIClient sharedClient].authenticationManager loggedInUser].agency.dispatcherSecondaryPhoneNumber;
    if (!number) {
        number = kEmergencyNumber;
    }
    
    if ([TSGeofence insideButClosed]) {
        [TSLocalNotification presentLocalNotification:[NSString stringWithFormat:kClosedNotification, number] openDestination:kAlertOutsideGeofence alertAction:@"Call"];
        _status = kAlertClosedDispatchCenter;
        NSLog(@"Closed dispatch center");
    }
    else {
        [TSLocalNotification presentLocalNotification:[NSString stringWithFormat:kOutsideNotification, number] openDestination:kAlertOutsideGeofence alertAction:@"Call"];
        _status = kAlertOutsideGeofence;
        NSLog(@"Outside geofence");
    }
    
    
    if ([_alertDelegate respondsToSelector:@selector(alertStatusChanged:)]) {
        [_alertDelegate alertStatusChanged:_status];
    }
    
    [[TSAlertManager sharedManager] callEmergencyNumber];
}

- (void)callPrimary {
    
    NSString *rawPhoneNum = [[TSJavelinAPIClient sharedClient].authenticationManager loggedInUser].agency.dispatcherPhoneNumber;
    if (rawPhoneNum) {
        [self voiceCall:rawPhoneNum];
    }
    else {
        [self callEmergencyNumber];
    }
}

- (void)stopEmergencyTimer {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [_emergencyCallTimer invalidate];
        _emergencyCallTimer = nil;
    }];
}

- (void)callEmergencyNumber {
    
    [self stopEmergencyTimer];
    
    _shouldMakeEmergencyCall = YES;
    
    NSString *rawPhoneNum = [[TSJavelinAPIClient sharedClient].authenticationManager loggedInUser].agency.dispatcherSecondaryPhoneNumber;
    if (!rawPhoneNum) {
#warning 911
        rawPhoneNum = kEmergencyNumber;
    }
    
    CTCallCenter *callCenter = [[CTCallCenter alloc] init];
    _currentCalls = callCenter.currentCalls;
    
    [self voiceCall:rawPhoneNum];
}

- (void)notifiedCTCallStateDialing:(CTCall *)call {
    
    if ([_currentCalls containsObject:call]) {
        return;
    }
    
    if (![TSAlertManager sharedManager].emergencyCall && _shouldMakeEmergencyCall && _isAlertInProgress) {
        [TSAlertManager sharedManager].emergencyCall = call;
    }
}

- (void)notifiedCTCallStateConnected:(CTCall *)call {
    
    if ([[TSAlertManager sharedManager].emergencyCall.callID isEqualToString:call.callID]) {
        [TSAlertManager sharedManager].emergencyCallStartTime = [NSDate date];
    }
}

- (void)notifiedCTCallStateDisconnected:(CTCall *)call {
    
    if ([[TSAlertManager sharedManager].emergencyCall.callID isEqualToString:call.callID]) {
        [[TSAlertManager sharedManager] emergencyCallDisconnected];
    }
}

- (void)notifiedCTCallStateIncoming:(CTCall *)call {
    
    
}

- (void)resetEmergencyCallStatus {
    
    _emergencyCallStartTime = nil;
    _emergencyCall = nil;
    _emergencyCallInProgress = NO;
    [self stopEmergencyTimer];
    _shouldMakeEmergencyCall = NO;
}

- (void)voiceCall:(NSString *)number {
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tel://"]]) {
        
        
        NSString *phoneNumber = [@"tel://" stringByAppendingString:number];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
        });
    }
    else {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"This device is not setup to make phone calls"
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.window.rootViewController  presentViewController:alertController animated:YES completion:nil];
        });
    }
}

- (void)emergencyCallDisconnected {
    
    _shouldMakeEmergencyCall = NO;
    
    NSTimeInterval callLength = 0;
    
    if (_emergencyCallStartTime) {
        callLength = [[NSDate date] timeIntervalSinceDate:_emergencyCallStartTime];
    }
    
    [[TSJavelinAlertManager sharedManager] updateAlertWithCallLength:callLength completion:nil];
}

//Disarm used if was previously disarmed by user but tasks like sending alert were still in progress
- (void)silentDisarmAlert {
    
    [self stopAlertCountdown];
    [self resetEmergencyCallStatus];
    _isAlertInProgress = NO;
    [self endTwilioCall];
    [[TSJavelinAPIClient sharedClient] disarmAlert];
    [[TSJavelinAPIClient sharedClient] cancelAlert];
    _type = nil;
    _endDate = nil;
    _status = kAlertSend;
    _shouldStartTimer = YES;
}

- (void)disarmAlert {
    
    _shouldStopTimer = YES;
    [self silentDisarmAlert];
    
    [[TSLocationController sharedLocationController] bestAccuracyForBattery];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
        [self dismissWindowWithAnimationType:kAlertWindowAnimationTypeZoomIn completion:nil];
    }];
    
    if ([TSEntourageSessionManager sharedManager].isEnabled &&
        ![TSEntourageSessionManager sharedManager].endTimer) {
        [[TSEntourageSessionManager sharedManager] recalculateEntourageTimerETA];
    }
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
    
    if ([[TSAlertManager sharedManager].status isEqualToString:kAlertOutsideGeofence] ||
        [[TSAlertManager sharedManager].status isEqualToString:kAlertClosedDispatchCenter]) {
        [self callEmergencyNumber];
        return;
    }
    
    
    if (![(TSAppDelegate *)[UIApplication sharedApplication].delegate isConnected]) {
        [self callPrimary];
        return;
    }
    
    [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
        if (!granted) {
            // Microphone disabled code
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Microphone Access Was Denied."
                                                                                     message:@"You will not be heard during VOIP phone services.\n\nPlease enable Microphone access for this app in Settings -> Privacy -> Microphone"
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [TSAppDelegate openSettings];
            }]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
            });
        }
        [self connectToDispatcher];
    }];
}

- (void)connectToDispatcher {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationStateActive object:nil];
    
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(connectToDispatcher)
                                                     name:UIApplicationDidBecomeActiveNotification
                                                   object:nil];
        return;
    }
    
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
        
        
        NSString *phoneNumber = [TSGeofence primaryPhoneNumberInsideRegion:[TSLocationController sharedLocationController].location
                                                                    agency:[[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].agency];
        
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
    
    if (!_isAlertInProgress) {
        [self silentDisarmAlert];
    }
}

- (void)connectionDidConnect:(TCConnection *)connection {
    
    _callStartTime = [NSDate date];
    
    if ([_callDelegate respondsToSelector:@selector(connectionDidConnect:)]) {
        [_callDelegate connectionDidConnect:connection];
    }
    
    if (!_isAlertInProgress) {
        [self silentDisarmAlert];
    }
}


- (void)connectionDidDisconnect:(TCConnection *)connection {
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    
    _callStartTime = nil;
    _callInProgress = NO;
    
    if ([_callDelegate respondsToSelector:@selector(connectionDidDisconnect:)]) {
        [_callDelegate connectionDidDisconnect:connection];
    }
}

- (void)connection:(TCConnection *)connection didFailWithError:(NSError *)error {
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    
    _callStartTime = nil;
    _callInProgress = NO;
    
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

- (void)didFindConnection:(NSNotification *)notification {
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [_noConnectionAlertController dismissViewControllerAnimated:YES completion:nil];
        
        if ([_previousStatus isEqualToString:kAlertSending]) {
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
        }
        
        _status = _previousStatus;
        _previousStatus = nil;
        if ([_alertDelegate respondsToSelector:@selector(alertStatusChanged:)]) {
            [_alertDelegate alertStatusChanged:_status];
        }
    }];
}

- (void)didLoseConnection:(NSNotification *)notification {
    
    _previousStatus = _status;
    
    _status = kAlertNoConnection;
    if ([_alertDelegate respondsToSelector:@selector(alertStatusChanged:)]) {
        [_alertDelegate alertStatusChanged:_status];
    }
}


#pragma mark UIWindow


- (void)showWindowWithRootViewController:(UIViewController *)viewController animated:(BOOL)animated animationType:(NSString *)type completion:(void (^)(BOOL finished))completion {
    
    _isPresented = YES;
    
    if (_window.isKeyWindow) {
        animated = NO;
    }
    else {
       [[UIApplication sharedApplication].delegate.window makeKeyAndVisible]; 
    }
    
    [self showWindowWithRootViewController:viewController];
    
    UIViewController *viewcontroller = [[UIApplication sharedApplication].delegate.window.rootViewController.childViewControllers firstObject];
    
    [viewcontroller beginAppearanceTransition:NO animated:animated];
    
    if (animated) {
        
        if (type == kAlertWindowAnimationTypeZoomIn) {
            _window.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.001, 0.001), CGAffineTransformMakeRotation(8 * M_PI));
        }
        else if (type == kAlertWindowAnimationTypeZoomOut) {
            _window.alpha = 0.0f;
            _window.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(3.0, 3.0), CGAffineTransformMakeRotation(8 * M_PI));
        }
        else {
            CGRect frame = [UIScreen mainScreen].bounds;
            frame.origin.y = frame.size.height;
            _window.frame = frame;
        }
        
        
        
        [UIView animateWithDuration:0.3
                              delay:0
             usingSpringWithDamping:300.0
              initialSpringVelocity:5.0
                            options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             if (type == kAlertWindowAnimationTypeDown) {
                                 _window.frame = [UIScreen mainScreen].bounds;
                             }
                             else {
                                _window.transform = CGAffineTransformIdentity;
                             }
                             _window.alpha = 1.0f;
                         } completion:^(BOOL finished) {
                             [viewcontroller endAppearanceTransition];
                             if (completion) {
                                 completion(finished);
                             }
                         }];
    }
    else {
        [viewcontroller endAppearanceTransition];
    }
}

- (void)showWindowWithRootViewController:(UIViewController *)viewController {
    
    if (!_window) {
        _window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _window.backgroundColor = [UIColor clearColor];
        _window.windowLevel = 0.2;
    }
    
    if (viewController) {
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        _window.rootViewController = navigationController;
    }
    
    [_window makeKeyAndVisible];
}

- (void)dismissWindowWithAnimationType:(NSString *)type completion:(void (^)(BOOL finished))completion  {
    
    [_homeViewController mapAlertModeToggle];
    [_homeViewController whiteNavigationBar];
    [[TSReportAnnotationManager sharedManager] showSpotCrimes];
    
    UIWindow *mainWindow = [UIApplication sharedApplication].delegate.window;
    if (!_window) {
        [mainWindow makeKeyAndVisible];
        return;
    }
    
    CGAffineTransform dismissedTransform = CGAffineTransformIdentity;
    float alpha = 1.0;
    CGRect frame = [UIScreen mainScreen].bounds;
    
    if ([type isEqualToString:kAlertWindowAnimationTypeZoomIn]) {
        dismissedTransform = CGAffineTransformConcat(CGAffineTransformMakeScale(1.5, 1.5), CGAffineTransformMakeRotation(8 * M_PI));
        alpha = 0.0;
    }
    else {
        frame.origin.y = frame.size.height;
    }
    
    
    UIViewController *rootView = _window.rootViewController.presentedViewController;
    if (!rootView) {
        rootView = _window.rootViewController;
    }
    TSChatViewController *chatVC;
    
    for (id vc in rootView.childViewControllers) {
        if ([vc isKindOfClass:[TSChatViewController class]]) {
            chatVC = vc;
            break;
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [chatVC.textMessageBarAccessoryView.textView resignFirstResponder];
        [[chatVC.view findFirstResponder] resignFirstResponder];
        
        
        UIViewController *viewcontroller = [mainWindow.rootViewController.childViewControllers firstObject];
        
        _isPresented = NO;
        
        [viewcontroller beginAppearanceTransition:YES animated:YES];
        
        [UIView animateWithDuration:0.5
                              delay:0
             usingSpringWithDamping:300.0
              initialSpringVelocity:5.0
                            options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             
                             [chatVC.inputAccessoryView setAlpha:0.0];
                             [chatVC.inputAccessoryView setUserInteractionEnabled:NO];
                             
                             if (type == kAlertWindowAnimationTypeDown) {
                                 _window.frame = frame;
                             }
                             else {
                                 _window.transform = dismissedTransform;
                             }
                             _window.alpha = alpha;
                             
                         } completion:^(BOOL finished) {
                             
                             [chatVC.textMessageBarAccessoryView setAlpha:0.0];
                             [chatVC.textMessageBarAccessoryView setUserInteractionEnabled:NO];
                             
                             if (completion) {
                                 completion(finished);
                             }
                             
                             [chatVC.view.findFirstResponder resignFirstResponder];
                             
                             
                             _pageviewController = nil;
                             [viewcontroller endAppearanceTransition];
                             [mainWindow makeKeyAndVisible];
                             _window = nil;
                         }];
    });
}

@end
