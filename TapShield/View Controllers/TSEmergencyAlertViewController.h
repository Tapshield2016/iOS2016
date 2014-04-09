//
//  TSEmergencyAlertViewViewController.h
//  TapShield
//
//  Created by Adam Share on 3/6/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseViewController.h"

@interface TSEmergencyAlertViewController : TSBaseViewController

@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *dispatcherLabel;
@property (weak, nonatomic) IBOutlet UILabel *callTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *alertInfoLabel;
@property (weak, nonatomic) IBOutlet TSCircularButton *speakerButton;
@property (weak, nonatomic) IBOutlet TSCircularButton *redialButton;
@property (weak, nonatomic) IBOutlet TSCircularButton *chatButton;

- (IBAction)showDisarmView:(id)sender;
- (IBAction)speakerPhoneToggle:(id)sender;
- (IBAction)redialPhoneNumber:(id)sender;
- (IBAction)showChatViewController:(id)sender;


@end
