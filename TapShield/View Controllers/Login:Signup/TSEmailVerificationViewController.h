//
//  TSEmailVerificationViewController.h
//  TapShield
//
//  Created by Adam Share on 2/18/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSBaseViewController.h"
#import "TSRegistrationTextField.h"
#import "TSRegistrationButton.h"
#import "TSRegistrationLabel.h"

@interface TSEmailVerificationViewController : TSBaseViewController

@property (strong, nonatomic) TSJavelinAPIUser *user;

@property (weak, nonatomic) IBOutlet TSRegistrationTextField *emailTextField;
@property (weak, nonatomic) IBOutlet TSRegistrationLabel *errorMessageLabel;
@property (weak, nonatomic) IBOutlet TSRegistrationButton *completeVerificationButton;
@property (weak, nonatomic) IBOutlet TSRegistrationButton *resendEmailButton;

- (void)segueToPhoneVerification;

@end
