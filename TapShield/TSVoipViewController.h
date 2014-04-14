//
//  TSVoipViewController.h
//  TapShield
//
//  Created by Adam Share on 4/10/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSNavigationViewController.h"
#import "TwilioClient.h"
#import "TSRoundRectButton.h"


@interface TSVoipViewController : TSNavigationViewController <TCConnectionDelegate, TCDeviceDelegate>

@property (weak, nonatomic) IBOutlet TSBaseLabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet TSBaseLabel *dispatcherLabel;
@property (weak, nonatomic) IBOutlet TSBaseLabel *callTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet UIView *buttonView;
@property (weak, nonatomic) IBOutlet TSRoundRectButton *redialButton;
@property (weak, nonatomic) IBOutlet TSRoundRectButton *addAlertDetailsButton;
@property (weak, nonatomic) IBOutlet TSCircularButton *speakerButton;
@property (weak, nonatomic) IBOutlet TSCircularButton *muteButton;
@property (weak, nonatomic) IBOutlet TSCircularButton *chatButton;

@property (strong, nonatomic) UIViewController *emergencyView;

@property (strong, nonatomic) TCDevice *twilioDevice;
@property (strong, nonatomic) TCConnection *twilioConnection;

- (void)startTwilioCall;

- (IBAction)addAlertDetails:(id)sender;
- (IBAction)showChatViewController:(id)sender;
- (IBAction)redialTwilio:(id)sender;
- (IBAction)speakerToggle:(id)sender;
- (IBAction)muteToggle:(id)sender;

@end
