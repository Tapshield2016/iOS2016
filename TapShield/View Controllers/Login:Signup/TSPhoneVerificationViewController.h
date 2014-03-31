//
//  TSPhoneVerificationViewController.h
//  TapShield
//
//  Created by Adam Share on 2/18/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSNavigationViewController.h"
#import "TSRegistrationTextField.h"
#import "TSRegistrationButton.h"
#import "TSRegistrationLabel.h"

@interface TSPhoneVerificationViewController : TSNavigationViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet TSRegistrationTextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet TSRegistrationTextField *verificationCodeTextField;
@property (weak, nonatomic) IBOutlet TSRegistrationButton *resendButton;
@property (weak, nonatomic) IBOutlet TSRegistrationLabel *errorLabel;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@end
