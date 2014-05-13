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
    
    if ([TSAlertManager sharedManager].callStartTime) {
        [self connectionDidConnect:nil];
    }
    
    [TSAlertManager sharedManager].callDelegate = self;
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
    
    [[TSAlertManager sharedManager] startTwilioCall];
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


#pragma mark - Actions


- (void)setMuteEnabled:(BOOL)enabled {
    [TSAlertManager sharedManager].twilioConnection.muted = enabled;
    
    _muteButton.selected = [TSAlertManager sharedManager].twilioConnection.muted;
}

- (void)setSpeakerEnabled:(BOOL)enabled {
	_speakerEnabled = [[TSAlertManager sharedManager] updateAudioRoute:enabled];
    
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
    
    NSTimeInterval seconds = abs([[TSAlertManager sharedManager].callStartTime timeIntervalSinceNow]);
    
    ((TSEmergencyAlertViewController *)_emergencyView).callTimeLabel.text = [TSUtilities formattedStringForTime:seconds];
}

#pragma mark - Twilio Connection Delegate

- (void)connectionDidStartConnecting:(TCConnection *)connection {
    
    _redialButton.enabled = NO;
}

- (void)connectionDidConnect:(TCConnection *)connection {
    [self startCallTimer];
    [self showPhoneNumber];
    
    _redialButton.enabled = NO;
}


- (void)connectionDidDisconnect:(TCConnection *)connection {
    [self stopCallTimer];
    _redialButton.enabled = YES;
    [self updatePhoneNumberWithMessage:kCallEnded];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [(TSEmergencyAlertViewController *)_emergencyView performSelector:@selector(dismissPhoneView) withObject:self afterDelay:2.0];
    });
}

- (void)connection:(TCConnection *)connection didFailWithError:(NSError *)error {
    [self stopCallTimer];
    _redialButton.enabled = YES;
    [self updatePhoneNumberWithMessage:kCallFailed];
}

@end
