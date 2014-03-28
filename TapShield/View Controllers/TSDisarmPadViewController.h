//
//  TSDisarmPadViewController.h
//  TapShield
//
//  Created by Adam Share on 3/4/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseViewController.h"
#import "TSCircularButton.h"
#import "TSGradientSwipeViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface TSDisarmPadViewController : TSBaseViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *disarmTextField;
@property (weak, nonatomic) IBOutlet UIView *codeCircleContainerView;
@property (weak, nonatomic) IBOutlet TSCircularButton *codeCircle1;
@property (weak, nonatomic) IBOutlet TSCircularButton *codeCircle2;
@property (weak, nonatomic) IBOutlet TSCircularButton *codeCircle3;
@property (weak, nonatomic) IBOutlet TSCircularButton *codeCircle4;
@property (weak, nonatomic) IBOutlet UIButton *emergencyButton;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, nonatomic) IBOutlet UIView *swipeLabelView;
@property (strong, nonatomic) TSGradientSwipeViewController *swipeViewController;

@property (strong, nonatomic) NSArray *codeCircleArray;
@property (strong, nonatomic) NSTimer *sendEmergencyTimer;

@property (nonatomic) BOOL isSendingAlert;

- (IBAction)numberPressed:(id)sender;
- (IBAction)clearDisarmText:(id)sender;
- (IBAction)deleteDisarmText:(id)sender;
- (IBAction)sendEmergency:(id)sender;

@end
