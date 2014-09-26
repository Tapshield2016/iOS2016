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
#import "TSPageViewController.h"

NSString * const kAlertWindowAnimationTypeDown = @"Down";
NSString * const kAlertWindowAnimationTypeZoom = @"Zoom";

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

- (void)setCurrentHomeViewController:(TSHomeViewController *)viewController {
    
    _pageviewController.homeViewController = viewController;
}

- (void)showAlertWindowAndStartCountdownWithType:(NSString *)type currentHomeView:(TSHomeViewController *)homeViewController {
    
    if (_isPresented){
        return;
    }
    _isPresented = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[TSAlertManager sharedManager] startAlertCountdown:10 type:type];
        
        _pageviewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TSPageViewController class])];
        _pageviewController.homeViewController = homeViewController;
        [self showWindowWithRootViewController:_pageviewController animated:YES animationType:kAlertWindowAnimationTypeZoom completion:nil];
    });
}

- (void)showAlertWindowForChatWithCurrentHomeView:(TSHomeViewController *)homeViewController {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        _pageviewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:NSStringFromClass([TSPageViewController class])];
        _pageviewController.isChatPresentation = YES;
        _pageviewController.homeViewController = homeViewController;
        [self showWindowWithRootViewController:_pageviewController animated:YES animationType:kAlertWindowAnimationTypeDown completion:nil];
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
    
    if (_shouldStopTimer) {
        return;
    }
    
    AudioServicesPlaySystemSound( kSystemSoundID_Vibrate );
    
    if ([_endDate timeIntervalSinceNow] <= 0) {
        [self sendAlert:nil];
    }
}

- (void)sendAlert:(NSString *)type {
    
    if (!type) {
        type = _type;
    }
    
    _isAlertInProgress = YES;
    
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
        
        _noConnectionAlertController = [UIAlertController alertControllerWithTitle:@"No Network Data Connection"
                                                                           message:nil
                                                                    preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:callButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self callSecondary];
        }];
        [_noConnectionAlertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
        [_noConnectionAlertController addAction:action];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.window.rootViewController presentViewController:_noConnectionAlertController animated:YES completion:nil];
        }];
        
        [TSLocalNotification presentLocalNotification:[NSString stringWithFormat:kNoConnectionNotification, number] openDestination:kAlertOutsideGeofence alertAction:@"Call"];
    }
    
    [[TSJavelinAPIClient sharedClient] sendEmergencyAlertWithAlertType:type location:[TSLocationController sharedLocationController].location completion:^(BOOL sent, BOOL inside) {
        
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
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"This device is not setup to make phone calls"
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.window.rootViewController  presentViewController:alertController animated:YES completion:nil];
        });
    }
}

//Disarm used if was previously disarmed by user but tasks like sending alert were still in progress
- (void)silentDisarmAlert {
    
    [self stopAlertCountdown];
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
    [self stopAlertCountdown];
    _isAlertInProgress = NO;
    [self endTwilioCall];
    [[TSJavelinAPIClient sharedClient] disarmAlert];
    [[TSJavelinAPIClient sharedClient] cancelAlert];
    _type = nil;
    _endDate = nil;
    _status = kAlertSend;
    _shouldStartTimer = YES;
    
    [[TSLocationController sharedLocationController] bestAccuracyForBattery];
    
    if (_window.rootViewController) {
        UINavigationController *navController = (UINavigationController *)_window.rootViewController;
        id controller = [navController.viewControllers firstObject];
        if ([[navController.viewControllers firstObject] isKindOfClass:[TSPageViewController class]]) {
            TSPageViewController *pageController = controller;
            [pageController.homeViewController mapAlertModeToggle];
            [pageController.homeViewController whiteNavigationBar];
            [pageController.homeViewController.reportManager showSpotCrimes];
        }
    }
    
    [self dismissWindowWithAnimationType:kAlertWindowAnimationTypeZoom completion:nil];
    
    if ([TSVirtualEntourageManager sharedManager].isEnabled &&
        ![TSVirtualEntourageManager sharedManager].endTimer) {
        [[TSVirtualEntourageManager sharedManager] recalculateEntourageTimerETA];
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

- (void)didFindConnection {
    
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

- (void)didLoseConnection {
    
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
    
    if (animated) {
        
        if ([type isEqualToString:kAlertWindowAnimationTypeZoom]) {
            _window.transform = CGAffineTransformConcat(CGAffineTransformMakeScale(0.001, 0.001), CGAffineTransformMakeRotation(8 * M_PI));
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
                             if ([type isEqualToString:kAlertWindowAnimationTypeZoom]) {
                                 _window.transform = CGAffineTransformIdentity;
                             }
                             else {
                                 _window.frame = [UIScreen mainScreen].bounds;
                             }
                         } completion:completion];
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
    
    UIWindow *mainWindow = [UIApplication sharedApplication].delegate.window;
    if (!_window) {
        [mainWindow makeKeyAndVisible];
        return;
    }
    
    CGAffineTransform dismissedTransform = CGAffineTransformIdentity;
    float alpha = 1.0;
    CGRect frame = [UIScreen mainScreen].bounds;
    
    if ([type isEqualToString:kAlertWindowAnimationTypeZoom]) {
        dismissedTransform = CGAffineTransformConcat(CGAffineTransformMakeScale(1.5, 1.5), CGAffineTransformMakeRotation(8 * M_PI));
        alpha = 0.0;
    }
    else {
        frame.origin.y = frame.size.height;
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIViewController *viewcontroller = [mainWindow.rootViewController.childViewControllers firstObject];
        
        _isPresented = NO;
        
        [viewcontroller beginAppearanceTransition:YES animated:YES];
        
        [UIView animateWithDuration:0.5
                              delay:0
             usingSpringWithDamping:300.0
              initialSpringVelocity:5.0
                            options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             
                             if ([type isEqualToString:kAlertWindowAnimationTypeZoom]) {
                                 _window.transform = dismissedTransform;
                             }
                             else {
                                 _window.frame = frame;
                             }
                             _window.alpha = alpha;
                             
                         } completion:^(BOOL finished) {
                             
                             if (completion) {
                                 completion(finished);
                             }
                             
                             _pageviewController = nil;
                             [viewcontroller endAppearanceTransition];
                             [mainWindow makeKeyAndVisible];
                             _window = nil;
                         }];
    });
}

@end
