//
//  TSAddSecondaryViewController.h
//  TapShield
//
//  Created by Adam Share on 8/15/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSNavigationViewController.h"
#import "TSRegistrationButton.h"
#import "TSRegistrationTextField.h"
#import "TSRegistrationLabel.h"

@interface TSAddSecondaryViewController : TSNavigationViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet TSRegistrationTextField *emailTextField;
@property (weak, nonatomic) IBOutlet TSRegistrationButton *completeButton;
@property (weak, nonatomic) IBOutlet TSRegistrationButton *resendButton;

@property (weak, nonatomic) IBOutlet TSRegistrationLabel *topLabel;
@property (weak, nonatomic) IBOutlet TSRegistrationLabel *middleLabel;
@property (weak, nonatomic) IBOutlet TSRegistrationLabel *bottomLabel;

@property (strong, nonatomic) TSJavelinAPIAgency *agency;


- (IBAction)completeVerification:(id)sender;
- (IBAction)sendVerification:(id)sender;

@end
