//
//  TSEmergencyAlertViewViewController.h
//  TapShield
//
//  Created by Adam Share on 3/6/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSNavigationViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface TSEmergencyAlertViewController : TSNavigationViewController


@property (strong, nonatomic) TSBaseLabel *alertInfoLabel;
@property (weak, nonatomic) IBOutlet UIView *detailsButtonView;
@property (weak, nonatomic) IBOutlet UIView *alertButtonView;
@property (weak, nonatomic) IBOutlet UIView *chatButtonView;


@property (strong, nonatomic) UIViewController *pageViewController;
@property (strong, nonatomic) NSTimer *sendEmergencyTimer;

- (IBAction)addAlertDetails:(id)sender;
- (IBAction)callDispatcher:(id)sender;
- (IBAction)showChatViewController:(id)sender;

- (void)scheduleSendEmergencyTimer;
- (void)sendEmergency;

@end
