//
//  TSEmergencyAlertViewViewController.h
//  TapShield
//
//  Created by Adam Share on 3/6/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSNavigationViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "TSAlertManager.h"
#import "TSIconBadgeView.h"

@interface TSEmergencyAlertViewController : TSNavigationViewController <TSAlertDelegate>


@property (strong, nonatomic) TSBaseLabel *alertInfoLabel;
@property (weak, nonatomic) IBOutlet UIView *detailsButtonView;
@property (weak, nonatomic) IBOutlet UIView *alertButtonView;
@property (weak, nonatomic) IBOutlet UIView *chatButtonView;
@property (weak, nonatomic) IBOutlet UIView *bottomButtonContainerView;
@property (weak, nonatomic) IBOutlet UIView *phoneInfoLabelsView;

@property (weak, nonatomic) IBOutlet TSBaseLabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet TSBaseLabel *dispatcherNameLabel;
@property (weak, nonatomic) IBOutlet TSBaseLabel *callTimeLabel;

@property (weak, nonatomic) IBOutlet UIView *callTimerView;

@property (strong, nonatomic) TSIconBadgeView *badgeView;

@property (weak, nonatomic) UIViewController *superviewViewController;
@property (strong, nonatomic) NSTimer *sendEmergencyTimer;

- (IBAction)addAlertDetails:(id)sender;
- (IBAction)callDispatcher:(id)sender;
- (IBAction)showChatViewController:(id)sender;

- (void)parentScrollViewOffset:(float)offsetX;

- (void)showCallTimer;
- (void)hideCallTimer;
- (void)endCall;

-(void)dismissPhoneView;

@end
