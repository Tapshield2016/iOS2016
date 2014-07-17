//
//  TSDisarmPadViewController.h
//  TapShield
//
//  Created by Adam Share on 3/4/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSNavigationViewController.h"

@interface TSDisarmPadViewController : TSBaseViewController <UITextFieldDelegate, UIAlertViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *disarmTextField;
@property (weak, nonatomic) IBOutlet UIView *codeCircleContainerView;
@property (weak, nonatomic) IBOutlet TSCircularButton *codeCircle1;
@property (weak, nonatomic) IBOutlet TSCircularButton *codeCircle2;
@property (weak, nonatomic) IBOutlet TSCircularButton *codeCircle3;
@property (weak, nonatomic) IBOutlet TSCircularButton *codeCircle4;
@property (weak, nonatomic) IBOutlet TSBaseButton *emergencyButton;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;
@property (weak, nonatomic) IBOutlet UIView *swipeLabelView;

@property (strong, nonatomic) NSArray *codeCircleArray;

- (IBAction)numberPressed:(id)sender;
- (IBAction)clearDisarmText:(id)sender;
- (IBAction)deleteDisarmText:(id)sender;

@end
