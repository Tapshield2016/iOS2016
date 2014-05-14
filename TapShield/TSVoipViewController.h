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
#import "TSAlertManager.h"
#import "TSIconBadgeView.h"


@interface TSVoipViewController : TSNavigationViewController <TSCallDelegate>

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

@property (strong, nonatomic) TSIconBadgeView *badgeView;
@property (strong, nonatomic) UIViewController *emergencyView;

- (IBAction)addAlertDetails:(id)sender;
- (IBAction)showChatViewController:(id)sender;
- (IBAction)redialTwilio:(id)sender;
- (IBAction)speakerToggle:(id)sender;
- (IBAction)muteToggle:(id)sender;

- (void)unreadChatMessage;

@end
