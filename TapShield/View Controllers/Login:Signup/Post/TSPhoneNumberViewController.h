//
//  TSPhoneNumberViewController.h
//  TapShield
//
//  Created by Adam Share on 8/19/14.
//  Copyright (c) 2014 TapShield, LLC. All rights reserved.
//

#import "TSNavigationViewController.h"
#import "TSRegistrationButton.h"
#import "TSRegistrationTextField.h"
#import "TSRegistrationLabel.h"
#import "TSBorderedView.h"

@interface TSPhoneNumberViewController : TSNavigationViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet TSRegistrationButton *sendVerificationButton;
@property (weak, nonatomic) IBOutlet TSRegistrationTextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet TSRegistrationLabel *topLabel;
@property (weak, nonatomic) IBOutlet TSRegistrationTextField *codeTextField;
@property (weak, nonatomic) IBOutlet TSBorderedView *codeView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sendButtonTopLayout;

- (IBAction)sendVerification:(id)sender;

@end
