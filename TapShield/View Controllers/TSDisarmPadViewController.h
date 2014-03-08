//
//  TSDisarmPadViewController.h
//  TapShield
//
//  Created by Adam Share on 3/4/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseViewController.h"
#import "TSNumberPadButton.h"

@interface TSDisarmPadViewController : TSBaseViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *disarmTextField;
@property (weak, nonatomic) IBOutlet UIView *codeCircleContainerView;
@property (weak, nonatomic) IBOutlet TSNumberPadButton *codeCircle1;
@property (weak, nonatomic) IBOutlet TSNumberPadButton *codeCircle2;
@property (weak, nonatomic) IBOutlet TSNumberPadButton *codeCircle3;
@property (weak, nonatomic) IBOutlet TSNumberPadButton *codeCircle4;
@property (weak, nonatomic) IBOutlet UIButton *emergencyButton;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;

@property (strong, nonatomic) NSArray *codeCircleArray;
@property (strong, nonatomic) NSTimer *sendEmergencyTimer;
@property (strong, nonatomic) UIToolbar *toolbar;

@property (nonatomic) BOOL isSendingAlert;

- (IBAction)numberPressed:(id)sender;
- (IBAction)clearDisarmText:(id)sender;
- (IBAction)deleteDisarmText:(id)sender;
- (IBAction)sendEmergency:(id)sender;

+ (void)presentFromViewController:(UIViewController *)presentingController transitionDelegate:(id <UIViewControllerTransitioningDelegate>)delegate;

@end
