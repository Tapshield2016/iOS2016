//
//  TSVoipViewController.h
//  TapShield
//
//  Created by Adam Share on 4/10/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSNavigationViewController.h"


@interface TSVoipViewController : TSNavigationViewController

@property (weak, nonatomic) IBOutlet TSBaseLabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet TSBaseLabel *dispatcherLabel;
@property (weak, nonatomic) IBOutlet TSBaseLabel *callTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *timeView;

@property (strong, nonatomic) UIViewController *emergencyView;

- (IBAction)addAlertDetails:(id)sender;
- (IBAction)showChatViewController:(id)sender;

@end
