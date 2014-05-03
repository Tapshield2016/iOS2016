//
//  TSVoipViewController.m
//  TapShield
//
//  Created by Adam Share on 4/10/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSVoipViewController.h"
#import "TSEmergencyAlertViewController.h"
#import "TSPageViewController.h"

static NSString * const kCallEnded = @"Call Ended";
static NSString * const kCallFailed = @"Call Failed";
static NSString * const kCallRetrying = @"Call Retrying";
static NSString * const kCallConnecting = @"Calling";
static NSString * const kCallRedialing = @"Redialing";

@interface TSVoipViewController ()

@property (strong, nonatomic) NSString *callToken;
@property (assign, nonatomic) BOOL speakerEnabled;
@property (strong, nonatomic) NSTimer *callTimer;

@end

@implementation TSVoipViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    
    self.translucentBackground = YES;
    CGRect frame = self.view.frame;
    frame.origin.x -= frame.size.width;
    frame.size.width += frame.size.width;
    self.toolbar.frame = frame;
    
    [_buttonView insertSubview:self.toolbar atIndex:0];
    _buttonView.backgroundColor = [[TSColorPalette alertRed] colorWithAlphaComponent:0.2f];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)showChatViewController:(id)sender {
    
    TSEmergencyAlertViewController *emergencyView = (TSEmergencyAlertViewController *)_emergencyView;
    
    [emergencyView performSelectorOnMainThread:@selector(showChatViewController:) withObject:self waitUntilDone:YES];
}

- (IBAction)redialTwilio:(id)sender {
    
    [self startTwilioCall];
}

- (IBAction)speakerToggle:(id)sender {
    
    _speakerButton.selected = !_speakerButton.selected;
    
    [self setSpeakerEnabled:_speakerButton.selected];
}

- (IBAction)muteToggle:(id)sender {
    
    _muteButton.selected = !_muteButton.selected;
    
    [self setMuteEnabled:_muteButton.selected];
}

- (IBAction)addAlertDetails:(id)sender {
    
    [_emergencyView performSelectorOnMainThread:@selector(addAlertDetails:) withObject:self waitUntilDone:NO];
}

#pragma mark - UI Updates 

- (void)updatePhoneNumberWithMessage:(NSString *)string {
    dispatch_async(dispatch_get_main_queue(), ^{
    [((TSEmergencyAlertViewController *)_emergencyView).phoneNumberLabel setText:string withAnimationType:kCATransitionPush direction:kCATransitionFromRight duration:0.3];
    });
}

- (void)showPhoneNumber {
    
    [self updatePhoneNumberWithMessage:[TSUtilities formatPhoneNumber:[[[TSJavelinAPIClient sharedClient] authenticationManager] loggedInUser].agency.dispatcherPhoneNumber]];
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
    
    [self voipDisconnect];
    _redialButton.enabled = NO;
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    
    [self updatePhoneNumberWithMessage:kCallConnecting];
    
    [self getTwilioCallToken:^(NSString *callToken) {
        
        if (!callToken) {
            [self connection:nil didFailWithError:nil];
            return;
        }
        
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

- (void)setMuteEnabled:(BOOL)enabled {
    _twilioConnection.muted = enabled;
}

- (void)setSpeakerEnabled:(BOOL)enabled {
	_speakerEnabled = [self updateAudioRoute:enabled];
    
    _speakerButton.selected = _speakerEnabled;
}

#pragma mark - Call Timer

- (void)startCallTimer {
    
    if (!_callTimer) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [(TSEmergencyAlertViewController *)_emergencyView showCallTimer];
            _callTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                          target:self
                                                        selector:@selector(timerCountUp:)
                                                        userInfo:[NSDate date]
                                                         repeats:YES];
        });
    }
}

- (void)stopCallTimer {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [(TSEmergencyAlertViewController *)_emergencyView hideCallTimer];
    });
    
    [_callTimer invalidate];
    _callTimer = nil;
}

- (void)timerCountUp:(NSTimer *)timer {
    
    NSDate *date = timer.userInfo;
    NSTimeInterval seconds = abs([date timeIntervalSinceNow]);
    
    ((TSEmergencyAlertViewController *)_emergencyView).callTimeLabel.text = [TSUtilities formattedStringForTime:seconds];
}

#pragma mark - Twilio Connection Delegate

- (void)connectionDidStartConnecting:(TCConnection *)connection {
    
}

- (void)connectionDidConnect:(TCConnection *)connection {
    [self startCallTimer];
    [self showPhoneNumber];
}


- (void)connectionDidDisconnect:(TCConnection *)connection {
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [self stopCallTimer];
    _redialButton.enabled = YES;
    [self updatePhoneNumberWithMessage:kCallEnded];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [(TSEmergencyAlertViewController *)_emergencyView performSelector:@selector(dismissPhoneView) withObject:self afterDelay:2.0];
    });
}

- (void)connection:(TCConnection *)connection didFailWithError:(NSError *)error {
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    [self stopCallTimer];
    _redialButton.enabled = YES;
    [self updatePhoneNumberWithMessage:kCallFailed];
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

@end
